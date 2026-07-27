import streamlit as st
import pandas as pd
import pyodbc

st.set_page_config(
    page_title="Netherlands Population Analytics",
    page_icon="📊",
    layout="wide",
)

st.title("Netherlands Population Analytics")
st.write(
    "Interactive analysis of Dutch regional population trends "
    "using SQL Server, Python, and Streamlit."
)

@st.cache_data
def load_population_data() -> pd.DataFrame:
    """Load regional population data from the SQL Server analytics view."""

    connection_string = (
        "DRIVER={ODBC Driver 18 for SQL Server};"
        "SERVER=localhost\\SQLEXPRESS;"
        "DATABASE=NetherlandsHousingAnalytics;"
        "Trusted_Connection=yes;"
        "Encrypt=no;"
    )

    query = """
        SELECT
            region_name,
            year_value,
            total_population,
            male_percentage,
            female_percentage,
            population_change,
            population_growth_percentage,
            growth_rank
        FROM analytics.vw_regional_population_summary
        ORDER BY year_value, growth_rank, region_name;
    """

    with pyodbc.connect(connection_string) as connection:
        return pd.read_sql(query, connection)


try:
    population_df = load_population_data()

    st.success("Connected to SQL Server successfully.")

    # Dashboard filters
    st.sidebar.header("Filters")

    available_years = sorted(population_df["year_value"].unique())

    selected_year = st.sidebar.selectbox(
        "Select reporting year",
        options=available_years,
        index=len(available_years) - 1,
    )

    available_regions = sorted(population_df["region_name"].unique())

    selected_regions = st.sidebar.multiselect(
        "Select regions",
        options=available_regions,
        default=available_regions,
    )

    filtered_df = population_df[
        (population_df["year_value"] == selected_year)
        & (population_df["region_name"].isin(selected_regions))
    ]

    # Prevent errors when no regions are selected.
    if filtered_df.empty:
        st.warning("Select at least one region to display the dashboard.")
        st.stop()

    # Calculate dashboard KPI values.
    largest_population_row = filtered_df.loc[
        filtered_df["total_population"].idxmax()
    ]

    growth_data = filtered_df.dropna(
        subset=["population_growth_percentage"]
    )

    if not growth_data.empty:
        fastest_growth_row = growth_data.loc[
            growth_data["population_growth_percentage"].idxmax()
        ]

        fastest_growth_region = fastest_growth_row["region_name"]
        fastest_growth_percentage = fastest_growth_row[
            "population_growth_percentage"
        ]

        average_growth = growth_data[
            "population_growth_percentage"
        ].mean()
    else:
        fastest_growth_region = "Not available"
        fastest_growth_percentage = 0
        average_growth = 0

    # Display dashboard KPI cards.
    kpi_1, kpi_2, kpi_3 = st.columns(3)

    with kpi_1:
        st.metric(
            label="Largest Population",
            value=f"{largest_population_row['total_population']:,.0f}",
            help=f"Region: {largest_population_row['region_name']}",
        )

    with kpi_2:
        st.metric(
            label="Fastest-Growing Region",
            value=fastest_growth_region,
            delta=f"{fastest_growth_percentage:.2f}%",
        )

    with kpi_3:
        st.metric(
            label="Average Population Growth",
            value=f"{average_growth:.2f}%",
        )

    # Prepare regional population growth data for the selected year.
    chart_df = filtered_df.dropna(
        subset=["population_growth_percentage"]
    ).sort_values(
        by="population_growth_percentage",
        ascending=False,
    )

    st.subheader(f"Population Growth by Region — {selected_year}")

    st.bar_chart(
        chart_df,
        x="region_name",
        y="population_growth_percentage",
        x_label="Region",
        y_label="Population Growth (%)",
        use_container_width=True,
    )

        # Exclude the national total so smaller regional trends remain visible.
    trend_regions = [
        region
        for region in selected_regions
        if region != "Nederland"
    ]

    if trend_regions:
        trend_df = population_df[
            population_df["region_name"].isin(trend_regions)
        ].copy()

        # Treat reporting years as categories rather than continuous numbers.
        trend_df["year_value"] = trend_df["year_value"].astype(str)

        # Reshape the data so each region becomes a separate chart line.
        trend_chart_df = trend_df.pivot(
            index="year_value",
            columns="region_name",
            values="total_population",
        )

        st.subheader("Population Trend by Region")

        st.line_chart(
            trend_chart_df,
            x_label="Year",
            y_label="Total Population",
            use_container_width=True,
        )
    else:
        st.info(
            "Select at least one regional area besides Nederland "
            "to display the population trend chart."
        )

    st.subheader(f"Regional Population Data — {selected_year}")

    st.dataframe(
        filtered_df,
        use_container_width=True,
        hide_index=True,
    )

except Exception as error:
    st.error("The application could not connect to SQL Server.")
    st.exception(error)
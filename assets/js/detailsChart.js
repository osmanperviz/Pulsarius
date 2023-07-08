export const DatailsChartHook = {
  mounted() {
    let graph = {
      series: [],
      //   colors: ["#939db8", "#939db8", "#939db8"],
      chart: {
        tickPlacement: "between",
        type: "area",
        foreColor: "#999",
        height: 350,
        zoom: {
          type: "x",
          enabled: false,
          autoScaleYaxis: false,
        },
      },
      dataLabels: {
        enabled: false,
      },
      title: {
        text: "Response times",
        align: "left",
      },
      fill: {
        type: "gradient",
        gradient: {
          shadeIntensity: 1,
          inverseColors: false,
          opacityFrom: 0.5,
          opacityTo: 0,
          stops: [0, 90, 100],
        },
      },

      markers: {
        size: 0,
        strokeColor: "#fff",
        strokeWidth: 3,
        strokeOpacity: 1,
        fillOpacity: 1,
        style: "hollow",
        hover: {
          size: 6,
        },
      },
      grid: {
        padding: {
          top: 20,
        },
      },
      xaxis: {
        type: "datetime",
        label: {
          tooltip: {
            enabled: true,
            x: {
              title: {
                formatter: function formatter(val, a) {
                  return "Response time in ms:";
                },
              },
            },
            formatter: undefined,
            offsetY: 0,
            style: {
              fontSize: 0,
              fontFamily: 0,
            },
          },
        },
      },
      yaxis: {
        title: {
          text: "Response Time (MS)",
        },
      },
      tooltip: {
        fillSeriesColor: false,
        theme: null,
        enabled: true,
        y: {
          title: {
            formatter: function formatter(val, a) {
              return "Response time in ms:";
            },
          },
        },
        x: {
          show: true,
          format: "dd MMM yyyy  HH:mm tt",
        },
      },
    };

    let chart = new ApexCharts(this.el, graph);
    chart.render();

    this.handleEvent("response_time", ({ response_time }) => {
      chart.updateSeries([
        {
          data: response_time,
        },
      ]);
    });
  },
};

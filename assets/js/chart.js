
export const ChartHook = {
    mounted() {
        var spark4 = {
  chart: {
    id: 'spark4',
    type: 'area',
    height: 100,
    sparkline: {
      enabled: true
            },
          },

  series: [{
    data: [
    ]
          }],
  stroke: {
    show: true,
    width: 1.5,
    curve: 'smooth',
          },
  noData: {
    text: "No response data available for last hour.",
    align: 'center',
    verticalAlign: 'top',
    offsetX: 0,
    offsetY: 0,
    style: {
      color: "#fff",
      fontSize: '14px',
      fontFamily: undefined
    }
  },
  
  markers: {
    size: 0,
        strokeColor: "#fff",
        strokeWidth: 3,
        strokeOpacity: 1,
        fillOpacity: 1,
        hover: {
          size: 6
        }
  },
  grid: {
    padding: {
      top: 20,
    }
  },
  colors: ['#939db8', '#939db8', '#939db8'],
  tooltip: {
    fillSeriesColor: true,
    theme: null,
     enabled: true,
      y: {
      title: {
          formatter: function formatter(val, a) {
            return "Response time in ms:";
        }
      }
    }
          },
    xaxis: {
     crosshairs: {
      width: 1,
      type: 'datetime',
    },
    labels: {
      formatter: function (value) {
        return `Occured at: ${value}h`;
      }
    }
}
}

    let chart = new ApexCharts(this.el, spark4)
    chart.render()
    
    this.handleEvent("response_time", ({ response_time }) => {
      chart.updateSeries([{
        data: response_time
      }])
    })

}
}
import { drawLink } from "simplemde";

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
    //         fill: {
    //           opacity: 0.2,
    //           shadeIntensity: 0.2,
    // },

             },
  series: [{
    // data: [15, 75, 47, 65, 14, 32, 19, 54, 44, 61]
      data: [215, 270, 360, 520, 250, 730, 650, 553, 299, 917, 360, 1520, 850, 730, 650, 553, 299, 417, 215, 270, 360, 520, 250, 730, 650, 553, 299, 917, 360, 1520, 850, 730, 650, 553, 299, 417]
          }],
  //  labels: [...Array(24).keys()].map(n => `2018-09-0${n+1}`),

  yaxis: {
    min: 0
  },
  stroke: {
    show: true,
    width: 1.5,
    curve: 'smooth',
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
      bottom: 10,
    }
  },
  colors: ['#939db8', '#9faac1', '#000'],
// colors: ['#008FFB'],
          xaxis: {
    crosshairs: {
      width: 1,
      type: 'datetime',
    },
  },
  tooltip: {
    fillSeriesColor: true,
    // theme: 'dark',
      enabled: true,
    x: {
      show: false
    },
      y: {
      title: {
          formatter: function formatter(val, a) {
          console.log(val)
            return "Miliseconds:";
        }
      }
    }
  }
}

        new ApexCharts(this.el, spark4).render()

}
}
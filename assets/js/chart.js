
export const ChartHook = {
    mounted() {
        const ctx = this.el.getContext('2d');

        const chart = new Chart(ctx, {
            // The type of chart we want to create
            type: 'line',
            // The data for our dataset
            data: {
                datasets: [{
                    label: 'Response times in milliseconds',
                    backgroundColor: 'rgb(255, 99, 132)',
                    borderColor: 'rgb(255, 99, 132)',
                    data: []
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false
            }
        });

        this.handleEvent("response_time", ({ response_time }) => {
            console.log(response_time)
            chart.data.datasets[0].data = response_time
            chart.update()
        })
    }
}

export const ChartHook = {
    mounted() {
        var ctx = this.el.getContext('2d');

        new Chart(ctx, {
            // The type of chart we want to create
            type: 'line',
            // The data for our dataset
            data: {
                labels: ['04:00pm', '07:00pm', '10:00pm', '01:00am', '04:00am', '07:00pm', '10:00am', '01:00pm'],
                datasets: [{
                    label: 'My First dataset',
                    backgroundColor: 'rgb(255, 99, 132)',
                    borderColor: 'rgb(255, 99, 132)',
                    data:  ['100', '250', '100', '500', '220', '150', '1500', "600"]
                }]
            },
            // Configuration options go here
            options: {
                responsive: true,
            maintainAspectRatio: false
            }
        });
    }
}
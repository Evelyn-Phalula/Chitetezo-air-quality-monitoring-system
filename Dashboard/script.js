// Fetch data from PHP script
fetch('get_data.php')
    .then(response => response.json())
    .then(data => {
        // Extract relevant data from the response
        const labels = data.map(item => item.label);
        const values = data.map(item => item.value);

        // Configure and render the chart
        const ctx = document.getElementById('myChart').getContext('2d');
        const chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Data',
                    data: values,
                    backgroundColor: 'rgba(0, 123, 255, 0.5)',
                    borderColor: 'rgba(0, 123, 255, 1)',
                    borderWidth: 1
                }]
            },
            options: {
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    })
    .catch(error => {
        console.error('Error:', error);
    });

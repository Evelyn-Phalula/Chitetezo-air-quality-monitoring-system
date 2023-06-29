from flask import Flask, render_template
import matplotlib.pyplot as plt
import pymysql

app = Flask(__name__)

# Connect to the database
connection = pymysql.connect(
    host='localhost',
    user='chitetezo',
    password='zuzu',
    database='chitetezo'
)

@app.route('/')
def index():
    # Retrieve data from the database
    cursor = connection.cursor()
    query = "SELECT data, date_time FROM air_quality"
    cursor.execute(query)
    data = cursor.fetchall()
    cursor.close()

    # Separate x and y data
    data = [row[0] for row in data]
    date_time = [row[1] for row in data]

    # Plot the graph
    plt.plot(data, date_time)
    plt.xlabel('Date')
    plt.ylabel('AQI')
    plt.title('Chitetezo Air Quality Levels')

    # Save the graph to a file
    graph_file = 'static/graph.png'
    plt.savefig(graph_file)
    plt.close()

    # Render the HTML template with the graph
    return render_template('graph.html', graph_file=graph_file)

if __name__ == '__main__':
    app.run()

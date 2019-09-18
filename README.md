# PageScraper

An Elixir-based page scraper app built on Phoenix.
It detects changes on a given web page and logs them to a database.
It uses Selenium and the Hound package to load pages in a Chrome session.
Currently, the app uses a single Chrome session, which has an impact on the polling speed when more than 1 pages are being polled at the same time.

## Installation

Please, use [Docker](https://docs.docker.com/) to use the app.

Run the below setup command to build the containers, create a new database and run the migrations. Please note, the command drops any existing database.
```
$ ./setup.sh
```

Start the app in development mode:
```
$ ./start.sh
```

Finally, load [http://localhost](http://localhost) in your browser.

## Running the tests

```
$ ./test.sh
```

## Details
Create a .env file in the app's root directory to use the below options.

To specify a Timezone, add the following environment variable to the file:
```
TZ=your_time_zone         Default: Europe/London
```

To specify the limit of logged changes per page, add the following environment variable to the file:
```
PAGE_CHANGES_LIMIT=100    Default: 100
```

## To-do list

* Add a Healthcheck to the page_scraper_selenium_chrome docker container
* Display live workers' status using channels/WebSockets
* Improve and finish off tests
* Improve frontend/design
* Implement a way to get page status before pulling page source
* Implement pagination
* Implement multiple Chrome sessions

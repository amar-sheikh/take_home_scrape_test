# take_home_scrape_test

## How to run

### build docker image
  `sudo docker build -t web-archiver .`

### run container
  `sudo docker run -it web-archiver bash`

### now we are inside the application container and we can run our application
  `bundle exec ruby processor.rb --metadata https://www.google.com`

### now we can see that there is a new file (www.google.com.html) and a new directory (www.google.com-files) in our app directory
`ls`

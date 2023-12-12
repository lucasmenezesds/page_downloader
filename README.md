# Page Downloader

## Installation

### Via Docker

Via command line, navigate to the project, then run the following commands:

1. Build the container by running
    - $`bin/app/build`
2. Start the container by running
    - $`bin/app/start`
    - **NOTE**: It's important to let you know that it's going to set a volume in your current directory
3. Access the container by running
    - $`bin/app/access`

4. Run the script by typing:
    - $ `exe/page_downloader --help`

5. When you finished using the project, feel free to delete the container by running (outside the container)
    - $ `bin/app/remove`

**NOTE**: Please take in consideration that depending on your local setup the files created by the script through the
docker might need to have the ownership of the files fix.

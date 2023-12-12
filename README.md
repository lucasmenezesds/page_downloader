# Page Downloader

## Installation

### Via Docker

Via command line, navigate to the project, then run the following commands:

1. Build the container by running
    - $`bin/app/build`
    - **NOTE**: This commands and the following will run Docker's commands so it might ask you to run in admin
      mode.
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

## Code Improvements

Here are some quick notes I too for improving the project

- Add more unit tests to parts that were not tested
- Extract methods to specialized classes
    - Create class: PageFetcher (for fetching the data)
    - Create class: PageSaver (for saving the pages and assets)
    - Create class: PageParser (for parsing the pages and collecting the metadata)
    - Create a class for UI (for the puts etc~)
    - Extract ProgressBar
- Create E2E tests
- Improve handling the errors
- Improve performance
    - Add parallel requests to download the assets
- Add feature to download the first level child pages with it's assets
- Add file checking to avoid downloading the same file twice
    - Adding a flag to fully re-download the page or not

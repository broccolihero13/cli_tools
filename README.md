# CLI Tools

A collection of Ruby CLI tools using [Thor](https://github.com/rails/thor) to help with common tasks.

---

## Prerequisites

- Ruby (3.0 or higher recommended)
- Bundler (install with `gem install bundler` if not already installed)

---

## Installation/quick start

1. Clone the repository:
   ```sh
   git clone https://github.com/<your-username>/cli_tools.git
   cd cli_tools
   ```

2. Install required gems:
   ```sh
   bundle install
   ```

3. Add aliases to .zshrc (optional):
  ```sh
  zsh add_aliases.sh
  ```

4. Add aliases to .bashrc (optional):
  ```sh
  bash add_aliases.sh
  ```
---

## Tools

### csv_to_json.rb

<details>
  <summary>Details for csv_to_json.rb</summary>

  ### Overview

  The `csv_to_json.rb` tool converts CSV files to JSON. It supports both standard CSV-to-JSON conversion and customizable JSON structures.

  ### Usage

  #### 1. Basic Conversion
  Converts a standard CSV file to JSON using the specified column as the key.

  ```sh
  ruby csv_to_json.rb convert sample.csv --key-column=1
  ```

  - **Input:** `sample.csv`
  - **Output:** `sample.json` (default output file based on the input filename)

  #### 2. Specify Output File
  Specify a custom output file name.

  ```sh
  ruby csv_to_json.rb convert sample.csv --key-column=1 --output=custom_output.json
  ```

  - **Input:** `sample.csv`
  - **Output:** `custom_output.json`

  #### 3. Custom JSON Structure
  Use a custom JSON structure by providing a template. Placeholders `<colX>` refer to columns in the CSV (e.g., `<col1>` for the first column).

  ```sh
  ruby csv_to_json.rb convert sample.csv --key-column=1 --customize-json='{"name": "<col1>", "age": "<col2>"}'
  ```

  - **Input:** `sample.csv`
  - **Template:** `{"name": "<col1>", "age": "<col2>"}`
  - **Output:** `sample.json` (default) or specified with `--output`.

  #### 4. Getting Help
  You can get help with the convert tool by using the following commands
  ```sh 
   ruby csv_to_json.rb convert -h
  ```
  or (if you're using the Terminal Alias)
  ```sh
  csvToJson -h
  ```

  ### Terminal Alias (Optional)

  For convenience, add an alias to your shell configuration file (e.g., `.bashrc`, `.zshrc`):

  ```sh
  alias csvToJson="ruby ~/<full>/<path>/<to>/cli_tools/csv_to_json.rb convert"
  ```

  Reload your shell configuration:
  ```sh
  source ~/.bashrc # or ~/.zshrc
  ```

  Now, you can run the tool using the alias:
  ```sh
  csvToJson sample.csv --key-column=1
  ```

  ### Examples

  #### Input CSV (`sample.csv`)
  ```csv
  name,age
  Alice,25
  Bob,30
  ```

  #### Example 1: Standard Conversion
  ```sh
  ruby csv_to_json.rb convert sample.csv --key-column=1
  ```

  **Output (`sample.json`):**
  ```json
  {
    "Alice": {
      "name": "Alice",
      "age": "25"
    },
    "Bob": {
      "name": "Bob",
      "age": "30"
    }
  }
  ```

  #### Example 2: Custom JSON Structure
  ```sh
  ruby csv_to_json.rb convert sample.csv --key-column=1 --customize-json='{"name": "<col1>", "age": "<col2>"}'
  ```

  **Output (`sample.json`):**
  ```json
  {
    "Alice": {
      "name": "Alice",
      "age": 25
    },
    "Bob": {
      "name": "Bob",
      "age": 30
    }
  }
  ```

  #### Example 3: Specify Output File
  ```sh
  ruby csv_to_json.rb convert sample.csv --key-column=1 --output=custom_output.json
  ```

  **Output (`custom_output.json`):**
  ```json
  {
    "Alice": {
      "name": "Alice",
      "age": "25"
    },
    "Bob": {
      "name": "Bob",
      "age": "30"
    }
  }
  ```

</details>

---

### component_duplicate.rb

<details>
  <summary>Details for component_duplicate.rb</summary>

  ### Overview

  The `component_duplicate.rb` tool duplicates JSX templates a specified number of times, with optional placeholder replacements. It supports multi-line JSX templates provided directly or through a file.

  ### Usage

  ```sh
  ruby component_duplicate.rb duplicate [ITERATIONS] [OPTIONS]
  ```

  ### Options:
  - **Input**: (Required) JSX template as a string or a file path containing the template.
  - **Replacement**: (Optional) Custom string to replace placeholders (`<placeholder>`).
  - **Output**: (Optional) File path to save the generated JSX code. If not provided, the code is displayed in the terminal.

  ### Examples

  #### 1. Single-Line JSX Template
  ```sh
  ruby component_duplicate.rb duplicate 3 --input='<div>Hello, <placeholder>!</div>' --replacement=World
  ```

  **Output:**
  ```html
  <div>Hello, World1!</div>
  <div>Hello, World2!</div>
  <div>Hello, World3!</div>
  ```

  #### 2. Multi-Line JSX Template
  ```sh
  ruby component_duplicate.rb duplicate 3 --input='<Section id="user<placeholder>">\n<Table id="userTable<placeholder>" rows={2}>\n<TableColumn id="subordinateNames<placeholder>" width={20}/>\n<TableColumn id="subordinatePositions<placeholder>" width={20}/>\n<TableColumn id="subordinatePayRates<placeholder>" width={20}/>\n</Table>\n</Section>' --replacement=User
  ```

  **Output:**
  ```html
  <Section id="userUser1">
  <Table id="userTableUser1" rows={2}>
  <TableColumn id="subordinateNamesUser1" width={20}/>
  <TableColumn id="subordinatePositionsUser1" width={20}/>
  <TableColumn id="subordinatePayRatesUser1" width={20}/>
  </Table>
  </Section>
  ```

  #### 3. Multi-Line JSX Template from File
  Save the template to a file (`template.jsx`):
  ```html
  <Section id="user<placeholder>">
  <Table id="userTable<placeholder>" rows={2}>
  <TableColumn id="subordinateNames<placeholder>" width={20}/>
  <TableColumn id="subordinatePositions<placeholder>" width={20}/>
  <TableColumn id="subordinatePayRates<placeholder>" width={20}/>
  </Table>
  </Section>
  ```

  Run the command:
  ```sh
  ruby component_duplicate.rb duplicate 3 --input=template.jsx --replacement=User
  ```

  #### 4. Getting Help
  You can get help with the duplicate tool by using the following commands
  ```sh 
   ruby component_duplicate.rb duplicate -h
  ```
  or (if you're using the Terminal Alias)
  ```sh
  duplicator -h
  ```

  ### Terminal Alias (Optional)

  For convenience, add an alias to your shell configuration file (e.g., `.bashrc`, `.zshrc`):

  ```sh
  alias duplicator="ruby ~/<full>/<path>/<to>/cli_tools/component_duplicate.rb duplicate"
  ```

  Reload your shell configuration:
  ```sh
  source ~/.bashrc # or ~/.zshrc
  ```

  Now, you can run the tool using the alias:
  ```sh
  duplicator 4 --input="<abc><placeholder></abc>"
  ```

</details>

---

### file_search.rb

<details>
  <summary>Details for file_search.rb</summary>

  ### Overview

  The `file_search.rb` tool recursively searches a folder for a substring. It supports an output file, extension specification, and exclusions

  ### Usage

  #### 1. Recursive Search
  Searches for a substring within a specified folder pattern

  ```sh
  ruby file_search.rb search '<folder_pattern>' '<substring>'
  ```

  ### Options:
  - **Ignore Case:** - ignores case-sensitivity
  - **Extensions:** `.js,.txt` - will only search through files with the extensions specified (separated by commas)
  - **Exclude:** `metadata.js,v-1` - will skip folders and files matching the patterns (separated by commas)

  #### 2. Specify Output File
  Specify a custom output file name.

  ```sh
  ruby file_search.rb search '<folder_pattern>' '<substring>' --output="results.txt"
  ```

  #### 3. Search specific file extensions
  Add the extensions flag to have the search only look in specific file types

  ```sh
  ruby file_search.rb search 'W*' "UUID" --extensions=".js,.jsx"
  ```

  #### 4. Exclude certain file and folder patterns
  Add the exclude flag to have the search ignore files and folder patterns

  ```sh
  ruby file_search.rb search 'W*' "UUID" --extensions=".js,.jsx"  --exclude="v-1,metadata.js"
  ```

  #### 5. Getting Help
  You can get help with the search tool by using the following commands
  ```sh 
   ruby file_search.rb search -h
  ```
  or (if you're using the Terminal Alias)
  ```sh
  fileSearch -h
  ```

  ### Terminal Alias (Optional)

  For convenience, add an alias to your shell configuration file (e.g., `.bashrc`, `.zshrc`):

  ```sh
  alias fileSearch="ruby ~/<full>/<path>/<to>/cli_tools/file_search.rb search"
  ```

  Reload your shell configuration:
  ```sh
  source ~/.bashrc # or ~/.zshrc
  ```

  Now, you can run the tool using the alias:
  ```sh
   fileSearch '*' "<substring>"
  ```

</details>

---

### json_diff.rb

<details>
  <summary>Details for json_diff.rb</summary>

  ### Overview

  The `json_diff.rb` tool compares two JSON files and displays the differences in a human-readable format. It can compare entire JSON structures or focus on a specific key using the `--comparable` flag.

  ### Usage

  #### 1. Basic Comparison
  Compare the entirety of two JSON files. It will output added, removed, or changed keys/values.

  ```sh
  ruby json_diff.rb diff file1.json file2.json
  ```

  #### 2. Specific Key Comparison
  If you want to only diff a specific field between the two files, you can use the `-c` or `--comparable` flag.

  ```sh
  ruby json_diff.rb diff file1.json file2.json -c myKey
  ```

  If the value of `myKey` is a string with line breaks in both files (like a JSX or template block), the tool will output a line-by-line breakdown of additions, removals, and changes.

  #### 3. Handling Large Diff Output
  By default, if the diff output is too large, the tool automatically saves the output to a text file rather than flooding the console. When saving to a file, all ANSI terminal color escape codes are automatically stripped so that the file is saved as clean, human-readable plain text.

  You can customize this behavior using the following options:

  - `--threshold`, `-t`: The maximum number of lines to print in the console before saving to a file instead (default: `50`).
  - `--char-limit`, `-l`: The maximum number of characters to print in the console before saving to a file instead (default: `2000`).
  - `--output`, `-o`: The output file name/path to save the diff to (default: `diff_output.txt` in the current working directory).

  ```sh
  ruby json_diff.rb diff file1.json file2.json -t 100 -l 5000 -o custom_diff.txt
  ```

  #### 4. Getting Help
  You can get help with the diff tool by using the following commands:

  ```sh
  ruby json_diff.rb diff -h
  ```
  or (if you're using the Terminal Alias)
  ```sh
  jsonDiff -h
  ```

  ### Terminal Alias (Optional)

  For convenience, add an alias to your shell configuration file (e.g., `.bashrc`, `.zshrc`):

  ```sh
  alias jsonDiff="ruby ~/<full>/<path>/<to>/cli_tools/json_diff.rb diff"
  ```

  Reload your shell configuration:
  ```sh
  source ~/.bashrc # or ~/.zshrc
  ```

  Now, you can run the tool using the alias:
  ```sh
  jsonDiff file1.json file2.json -c myKey
  ```

</details>

---
### api_looper.rb

<details>
  <summary>Details for api_looper.rb</summary>

  ### Overview

  The `api_looper.rb` tool converts loops through a CSV file and make API calls for each row, it then creates an output file that includes the results of the API calls.

  ### Usage

  #### 1. CSV Format
  The CSV requires a 'method' and 'endpoint' column and an optional (as needed) 'payload' column

  ```csv
  method,endpoint,payload
    PUT,https://demo1.api.droplet.io/v1/accounts/attributes,"{""accountId"":""GDBAlm"",""attributes"":{""state"":""active"",""region"":""CA"",""country"":""USA"",""fullName"":""Professor Plum"",""jobTitle"":""Professor"",""lastName"":""Plum"",""locality"":""Beverly Hills"",""username"":""professorplum"",""createdAt"":"""",""firstName"":""Professor"",""updatedAt"":"""",""externalId"":""45678"",""postalCode"":""90210"",""rawAddress"":"""",""divisionName"":"""",""employeeType"":""Suspect"",""managerEmail"":"""",""primaryEmail"":""plum@notanemailaddress.com"",""streetAddress"":""123 Street"",""costCenterName"":"""",""departmentName"":""Clue"",""secondaryEmail"":""proplum@notarealemail.com"",""customAttribute1"":""Purple"",""customAttribute2"":""Rope"",""customAttribute3"":""Hall"",""customAttribute4"":"""",""customAttribute5"":"""",""customAttribute6"":"""",""customAttribute7"":"""",""customAttribute8"":"""",""customAttribute9"":"""",""employmentStartDate"":""""}}"
  ```

  #### 2. Loop through CSV
  `loop` will go through the specified CSV file

  ```sh
  ruby api_looper.rb loop sample.csv
  ```

  - **Input:** `sample.csv`

  #### 3. Specify Output File and token
  Specify a custom output file name and token (the tool will prompt you if you don't include a token but it can be left blank)

  ```sh
  ruby api_looper.rb loop sample.csv thisOutputFile.csv --access_token 'abcdefghijklmnopqrstuv'
  ```

  - **Input:** `sample.csv`
  - **Output:** `thisOutputFile.csv`
  - **Token:** `abcdefghijklmnopqrstuv`

  #### 4. Getting Help
  You can get help with the loop tool by using the following commands
  ```sh 
   ruby api_looper.rb loop -h
  ```
  or (if you're using the Terminal Alias)
  ```sh
  apiLooper -h
  ```

  ### Terminal Alias (Optional)

  For convenience, add an alias to your shell configuration file (e.g., `.bashrc`, `.zshrc`):

  ```sh
  alias apiLooper="ruby ~/<full>/<path>/<to>/cli_tools/api_looper.rb loop"
  ```

  Reload your shell configuration:
  ```sh
  source ~/.bashrc # or ~/.zshrc
  ```

  Now, you can run the tool using the alias:
  ```sh
  apiLooper sample.csv --access_token 'abcdefghijklmnopqrstuv'
  ```

  ### Examples

  #### Input CSV (`sample.csv`)
  ```csv
  method,endpoint,payload
  GET,https://api.example.com/v1/status,
  POST,https://api.example.com/v1/users,"{""name"":""Alice""}"
  ```

  #### Example 1: Loop and Output to Custom File
  ```sh
  ruby api_looper.rb loop sample.csv output_results.csv --access_token 'my-access-token'
  ```

  **Output CSV (`output_results.csv`):**
  ```csv
  method,endpoint,timestamp,status,response_body
  GET,https://api.example.com/v1/status,2026-05-31T15:00:00Z,200,"{""status"":""OK""}"
  POST,https://api.example.com/v1/users,2026-05-31T15:00:01Z,201,"{""id"":123,""name"":""Alice""}"
  ```

</details>

---

### common_ids.rb

<details>
  <summary>Details for common_ids.rb</summary>

  ### Overview

  The `common_ids.rb` tool compares two files and returns IDs that can be found in BOTH files (ability to exclude items that start with a specific substring).

  ### Usage

  #### 1. File Format
  The files must contain a substring of `id="` and its corresponding closing quote `"`

  Example of two JSX files:
  
  File 1:
  ```jsx
  <Form color="#000000">
    <Section id="section1" display="false">
      <Computed
        id="siteDetails"
        label="SITE DETAILS"
        columns={3}
        formula="site ? locations[site] : false"
      />
      <Computed
        id="siteFullName"
        label="Site Full Name"
        columns={3}
        formula="siteDetails ? siteDetails.siteFullName : ''"
      />
      <Tile
        id="tile1"
        label="Site Full Name"
        columns={3}
      />
      <Computed
        id="secretaryAssigned"
        label="ROUTING:Secretary"
        columns={3}
        display="false"
        formula="siteDetails && siteDetails.routeSecretaryAsstEmail ? { name: siteDetails.routeSecretaryAsstName , email: siteDetails.routeSecretaryAsstEmail } : false"
      />
      <Computed
        id="principalAssigned"
        label="ROUTING:Principal"
        columns={3}
        display="false"
        formula="siteDetails && siteDetails.routePrincipalDirectorEmail ? { name: siteDetails.routePrincipalDirectorName , email: siteDetails.routePrincipalDirectorEmail } : false"
      />
    </Section>
  </Form>
  ```

  File 2:
  ```jsx
  <Form color="#000000">
    <Section id="section1" display="false">
      <Computed
        id="siteDetails"
        label="SITE DETAILS"
        columns={3}
        formula="site ? locations[site] : false"
      />
      <Computed
        id="notmatched"
        label="Site Full Name"
        columns={3}
        formula="siteDetails ? siteDetails.siteFullName : ''"
      />
      <Tile
        id="tile1"
        label="Site Full Name"
        columns={3}
      />
      <Computed
        id="secretaryAssigned"
        label="ROUTING:Secretary"
        columns={3}
        display="false"
        formula="siteDetails && siteDetails.routeSecretaryAsstEmail ? { name: siteDetails.routeSecretaryAsstName , email: siteDetails.routeSecretaryAsstEmail } : false"
      />
      <Computed
        id="principalAssigned"
        label="ROUTING:Principal"
        columns={3}
        display="false"
        formula="siteDetails && siteDetails.routePrincipalDirectorEmail ? { name: siteDetails.routePrincipalDirectorName , email: siteDetails.routePrincipalDirectorEmail } : false"
      />
    </Section>
  </Form>
  ```


  #### 2. Find Common IDs
  `common_ids` finds common IDs between the two files

  ```sh
  ruby common_ids.rb common_ids sample1.jsx sample2.jsx
  ```

  - **Input:** `sample1.jsx sample2.jsx`

  #### 3. Exclusions
  Specify IDs that you'd like to ignore

  ```sh
  ruby common_ids.rb common_ids sample1.jsx sample2.jsx --exclude tile section text line spacer rejected
  ```

  #### 4. Getting Help
  You can get help with the loop tool by using the following commands
  ```sh 
   ruby common_ids.rb common_ids -h
  ```
  or (if you're using the Terminal Alias)
  ```sh
  commonIds -h
  ```

  ### Terminal Alias (Optional)

  For convenience, add an alias to your shell configuration file (e.g., `.bashrc`, `.zshrc`):

  ```sh
  alias commonIds="ruby ~/<full>/<path>/<to>/cli_tools/common_ids.rb common_ids"
  ```

  Reload your shell configuration:
  ```sh
  source ~/.bashrc # or ~/.zshrc
  ```

  Now, you can run the tool using the alias:
  ```sh
  commonIds file1 file2 --exclude tile
  ```


</details>

---


---
### csv_xlsx_diff.rb

<details>
  <summary>Details for csv_xlsx_diff.rb</summary>

  ### Overview

  The `csv_xlsx_diff.rb` tool compares two CSV or XLSX files and displays the differences. It also allows you to sort by multiple columns prior to diffing and export the output as a CSV or XLSX file.

  ### Usage

  #### 1. Basic Comparison
  Compare two files and output the result to the console in a human-readable format.

  ```sh
  ruby csv_xlsx_diff.rb diff file1.csv file2.csv
  ```

  #### 2. Sorting
  Sort by one or more columns before comparing the files using the `-s` or `--sort-by` flag.

  ```sh
  ruby csv_xlsx_diff.rb diff file1.csv file2.csv -s 'First Name' 'Last Name'
  ```

  #### 3. Output Type
  Choose the output type using the `-o` or `--output-type` flag. By default, it outputs to the console (`none`), but it can also be exported as a `csv` or `xlsx`. You can specify the output file name with `--output-file`.

  ```sh
  ruby csv_xlsx_diff.rb diff file1.xlsx file2.xlsx -o xlsx --output-file differences.xlsx
  ```

  #### 4. Getting Help
  You can get help with the diff tool by using the following commands:

  ```sh
  ruby csv_xlsx_diff.rb diff -h
  ```
  or (if you're using the Terminal Alias)
  ```sh
  csvXlsxDiff -h
  ```

  ### Terminal Alias (Optional)

  For convenience, add an alias to your shell configuration file (e.g., `.bashrc`, `.zshrc`):

  ```sh
  alias csvXlsxDiff="ruby ~/<full>/<path>/<to>/cli_tools/csv_xlsx_diff.rb diff"
  ```

  Reload your shell configuration:
  ```sh
  source ~/.bashrc # or ~/.zshrc
  ```

  Now, you can run the tool using the alias:
  ```sh
  csvXlsxDiff file1.csv file2.csv -o csv
  ```

</details>

## Contributing

Contributions are welcome! Please fork the repository, make your changes, and submit a pull request.

---

## License

This project is open-source and available under the [MIT License](LICENSE).

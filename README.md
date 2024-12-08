# CLI Tools

A collection of Ruby CLI tools using [Thor](https://github.com/rails/thor) to help with common tasks.

## Prerequisites

- Ruby (3.0 or higher recommended)
- Bundler (install with `gem install bundler` if not already installed)

---

## Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/<your-username>/cli_tools.git
   cd cli_tools
   ```

2. Install required gems:
   ```sh
   bundle install
   ```

---

## csv_to_json.rb
<details>

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

---

## Development

If you want to modify or extend the functionality:

1. Make your changes to the `csv_to_json.rb` script.
2. Test your changes by running the script locally:
   ```sh
   ruby csv_to_json.rb convert test.csv --key-column=1
   ```

</details>
---
## component_duplicate.rb

<details>
### Overview

The `component_duplicate.rb` tool duplicates JSX templates a specified number of times, with optional placeholder replacements. It supports multi-line JSX templates provided directly or through a file.

### Usage

#### 1. Basic Conversion
Converts a standard CSV file to JSON using the specified column as the key.

```sh
ruby component_duplicate.rb duplicate [ITERATIONS] [OPTIONS]
```

#### 2. Options:
- **Input**: (Required) JSX template as a string or a file path containing the template.
- **Replacement**: (Optional) Custom string to replace placeholders (<placeholder>).
- **Output**: (Optional) File path to save the generated JSX code. If not provided, the code is displayed in the terminal.

- **Input:** `template.jsx`
- **Output:** `custom_output.jsx`


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
duplicator 3 --input=template.jsx
```

#### 3. Examples

##### 1. Single-Line JSX Template
```sh
ruby component_duplicate.rb duplicate 3 --input='<div>Hello, <placeholder>!</div>' --replacement=World
```
**Output:**
```html
<div>Hello, World1!</div>
<div>Hello, World2!</div>
<div>Hello, World3!</div>
```

##### 2. Multi-Line JSX Template
Provide the JSX template as a string:
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
<Section id="userUser2">
<Table id="userTableUser2" rows={2}>
<TableColumn id="subordinateNamesUser2" width={20}/>
<TableColumn id="subordinatePositionsUser2" width={20}/>
<TableColumn id="subordinatePayRatesUser2" width={20}/>
</Table>
</Section>
<Section id="userUser3">
<Table id="userTableUser3" rows={2}>
<TableColumn id="subordinateNamesUser3" width={20}/>
<TableColumn id="subordinatePositionsUser3" width={20}/>
<TableColumn id="subordinatePayRatesUser3" width={20}/>
</Table>
</Section>
```

##### 3. Multi-Line JSX Template from File
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

**Output:**
```html
<Section id="userUser1">
<Table id="userTableUser1" rows={2}>
<TableColumn id="subordinateNamesUser1" width={20}/>
<TableColumn id="subordinatePositionsUser1" width={20}/>
<TableColumn id="subordinatePayRatesUser1" width={20}/>
</Table>
</Section>
...
```

##### 4. Save Output to a File
```sh
ruby component_duplicate.rb duplicate 3 --input=template.jsx --replacement=User --output=output.jsx
```

**Output File (`output.jsx`)**:
```html
<Section id="userUser1">
<Table id="userTableUser1" rows={2}>
<TableColumn id="subordinateNamesUser1" width={20}/>
<TableColumn id="subordinatePositionsUser1" width={20}/>
<TableColumn id="subordinatePayRatesUser1" width={20}/>
</Table>
</Section>
...
```

---

### Error Handling

- **Missing Input:**
   ```sh
   Error: Input is required via the --input option.
   ```
- **Invalid Iterations:**
   ```sh
   Error: Iterations must be a positive integer.
   ```
- **Non-Existent File:**
   ```sh
   Error: Input file <file_path> does not exist.
   ```

</details>
---
## Contributing

Contributions are welcome! Please fork the repository, make your changes, and submit a pull request.

---

## License

This project is open-source and available under the [MIT License](LICENSE).

---

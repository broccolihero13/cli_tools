# CLI Tools

A collection of Ruby CLI tools using [Thor](https://github.com/rails/thor) to help with common tasks. This repository includes tools like `csv_to_json.rb` for converting CSV files to JSON format.

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

---

## Examples

### Input CSV (`sample.csv`)
```csv
name,age
Alice,25
Bob,30
```

### Example 1: Standard Conversion
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

### Example 2: Custom JSON Structure
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

### Example 3: Specify Output File
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

---

## Contributing

Contributions are welcome! Please fork the repository, make your changes, and submit a pull request.

---

## License

This project is open-source and available under the [MIT License](LICENSE).

---

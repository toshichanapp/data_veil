# DataVeil

DataVeil is a Ruby gem designed to mask sensitive data in your database for development and testing purposes. It provides a flexible way to define masking rules and apply them to your database tables.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'data_veil'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install data_veil
```

## Usage

### Configuration

1. Create a database configuration file (e.g., `config/mask_database.yml`) with your database settings:

```yaml
development:
  adapter: mysql2
  database: your_database_name
  username: your_username
  password: your_password
  host: localhost
```

2. Create a masking configuration file (e.g., `config/masking.yml`) to define your masking rules:

```yaml
your_database_name:
  users:
    email:
      type: email
    first_name:
      type: first_name
    last_name:
      type: last_name
    birth_date:
      type: date
      start_date: "1970-01-01"
      end_date: "2000-12-31"
    phone:
      type: tel
```

### Running the Masking Process

To run the masking process, use the following command:

```
$ data_veil mask -d path/to/mask_database.yml -m path/to/masking.yml -e development
```

Options:
- `-d, --database-config PATH`: Path to the database configuration file (default: "./config/mask_database.yml")
- `-m, --masking-config PATH`: Path to the masking configuration file (default: "./config/masking.yml")
- `-e, --environment ENV`: Environment (default: "development")

### Supported Masking Types

- `email`: Generates a random email address
- `string`: Generates a random string
- `password`: Generates a random password
- `tel`: Generates a random phone number
- `first_name`: Generates a random first name
- `last_name`: Generates a random last name
- `integer`: Generates a random integer within a specified range
- `date`: Generates a random date within a specified range
- `enum`: Selects a random value from a specified list

### Type-specific Options

Different masking types support different options:

- `string`:
  - `length`: The length of the generated string (default: 20)
- `password`:
  - `min_length`: Minimum length of the password (default: 10)
  - `max_length`: Maximum length of the password (default: 20)
- `integer`:
  - `min`: Minimum value (default: 0)
  - `max`: Maximum value (default: 100)
- `date`:
  - `start_date`: The earliest date to generate (format: "YYYY-MM-DD")
  - `end_date`: The latest date to generate (format: "YYYY-MM-DD")
- `enum`:
  - `values`: An array of possible values to choose from

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

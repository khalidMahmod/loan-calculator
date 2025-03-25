# Real Estate Calculator Suite

A comprehensive suite of property finance tools for real estate professionals in Malaysia, including mortgage, affordability, and investment ROI calculators.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Setting Up the Development Environment](#setting-up-the-development-environment)
- [Database Setup](#database-setup)
- [Running the Application](#running-the-application)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)

## Overview

This Real Estate Calculator Suite is designed to help property agents and buyers make informed financial decisions regarding property investments in Malaysia. The application includes specialized calculators for mortgage payments, property affordability, and return on investment analysis.

## Features

- **Mortgage Calculator**: Calculate monthly payments, amortization schedules, and total interest costs
- **Affordability Calculator**: Determine maximum affordable property price based on income and expenses
- **Investment ROI Calculator**: Analyze property investments with cash flow projections and ROI metrics
- **Coming Soon**: Rental Yield Calculator and Stamp Duty Calculator
- Export results to PDF and Excel for client presentations
- Malaysia-specific calculations and tax considerations

## Installation

### Prerequisites

- Ruby 3.2.2 or higher
- Rails 7.0.0 or higher
- PostgreSQL 14.0 or higher
- Node.js 16.0 or higher
- Yarn 1.22 or higher

### Clone the Repository

```bash
git clone https://github.com/username/real-estate-calculator.git
cd real-estate-calculator
```

### Install Dependencies

```bash
# Install Ruby dependencies
bundle install

# Install JavaScript dependencies
yarn install
```

## Setting Up the Development Environment

### Configure Environment Variables

Create a `.env` file in the root directory:

```bash
cp .env.example .env
```

Edit the `.env` file with your local configuration:

```
DATABASE_USERNAME=your_postgres_username
DATABASE_PASSWORD=your_postgres_password
DATABASE_HOST=localhost
RAILS_ENV=development
```

### Database Setup

Create and set up the database:

```bash
# Create the database
rails db:create

# Run migrations
rails db:migrate

# Seed the database with initial data
rails db:seed
```

## Running the Application

```bash
# Start the Rails server
rails server

# In a separate terminal, start the webpack dev server (if using webpack)
bin/webpack-dev-server
```

Visit `http://localhost:3000` in your browser to access the application.

## Testing

Run the test suite:

```bash
# Run all tests
rails test

# Run system tests
rails test:system
```

## Development Workflow

### Adding New Calculator

1. Create a new controller in the `app/controllers` directory
2. Add the corresponding views in `app/views`
3. Update routes in `config/routes.rb`
4. Add any needed JavaScript in `app/javascript/packs`
5. Add appropriate tests

### Styling Guidelines

This project uses a custom CSS framework defined in `atlas-calculators.css`. When adding new components:

1. Follow the existing class naming conventions
2. Maintain responsive design principles
3. Test across various device sizes

## Deployment

### Production Setup

Prepare the application for production:

```bash
# Precompile assets
RAILS_ENV=production rails assets:precompile

# Check for security vulnerabilities
bundle audit
```

### Deployment to Heroku

```bash
# Create a Heroku app
heroku create real-estate-calculator

# Push to Heroku
git push heroku main

# Run migrations on Heroku
heroku run rails db:migrate
```

## Troubleshooting

### Common Issues

- **Database Connection Issues**: Ensure PostgreSQL is running and credentials in `.env` are correct
- **JavaScript Not Loading**: Check that Yarn dependencies are installed and webpack is running
- **Styling Problems**: Verify the correct CSS classes are being used from `atlas-calculators.css`

### Debug Mode

To run the server in debug mode:

```bash
rails server --debug
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- Bootstrap for base styling components
- Recharts for data visualization
- PapaParse for CSV processing
- SheetJS for Excel export functionality

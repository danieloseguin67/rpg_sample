# Informix 4GL and RPG Programming Languages

This repository contains examples and code for both **Informix 4GL** and **RPG** programming languages, demonstrating the similarities and relationships between these two business-oriented programming languages.

## Language Similarities

Informix 4GL and RPG (Report Program Generator) share many fundamental characteristics that make them natural companions for business application development:

### 1. **Business-Oriented Design**
- Both languages were specifically designed for business applications
- Focus on database operations, reporting, and data processing
- Built-in support for common business logic patterns

### 2. **Database Integration**
- **Informix 4GL**: Native integration with Informix databases
- **RPG**: Strong integration with IBM DB2 and other database systems
- Both provide simplified syntax for database operations (SELECT, INSERT, UPDATE, DELETE)

### 3. **Record-Based Processing**
- Both languages excel at processing records and structured data
- Natural handling of database rows and file records
- Built-in looping constructs for record processing

### 4. **Form and Report Generation**
- **Informix 4GL**: Built-in form (.per files) and report capabilities
- **RPG**: Display files (DSPF) and printer files for user interfaces
- Both support screen-based applications with minimal coding

### 5. **Procedural Programming Style**
- Both follow procedural programming paradigms
- Linear execution flow with structured programming constructs
- Similar control structures (IF/ELSE, WHILE, FOR loops)

### 6. **Legacy System Support**
- Both languages are widely used in maintaining legacy business systems
- Strong backward compatibility
- Extensive existing codebases in enterprise environments

## Repository Structure

```
├── INFORMIX4gl/          # Informix 4GL examples and code
│   ├── musicorg.4gl      # Main 4GL program
│   ├── musiclist.per     # Form definition
│   └── songdetail.per    # Detail form
│
└── RPG/                  # RPG examples and code
    ├── MUSICPGM.SQLRPGLE # SQL RPG program
    ├── MUSICDSPF.DSPF    # Display file definition
    └── MUSICPGM_Flowchart.* # Program flowchart
```

## Key Differences

While similar in many ways, there are some notable differences:

- **Syntax**: Informix 4GL uses more English-like syntax, while RPG has a more structured, columnar format
- **Platform**: Informix 4GL is primarily Unix/Linux-based, while RPG is IBM i (AS/400) focused
- **Development Environment**: Different IDEs and development tools
- **Database Focus**: Informix 4GL is tightly coupled to Informix databases, RPG works with various databases

## Getting Started

- See [INFORMIX4gl/README.md](INFORMIX4gl/README.md) for Informix 4GL specific information
- See [RPG/README.md](RPG/README.md) for RPG specific information

Both languages demonstrate how business logic can be implemented efficiently with database-centric programming approaches, making them valuable tools for understanding legacy system architecture and maintenance.

Please note that these examples are intended for educational purposes and may require specific environments to run.

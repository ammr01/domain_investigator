
**domain_investigator: A Domain Information Gathering Tool**

**Description:**

This script automates the process of gathering information about domain names, including descriptions, registrant organizations, creation dates, and registry expiry dates.

**Installation:**

1. **Prerequisites:** Ensure you have `curl`, `dos2unix`, `sqlite3`, `per` and `whois` installed:
   ```bash
   sudo apt install curl dos2unix whois sqlite3 perl
   ```
2. **Download the project:** Download the project using `git clone https://github.com/ammr01/domain_investigator.git`.
3. **Make Executable:** Grant the script execute permission:
   ```bash
   cd domain_investigator
   chmod +x *.sh
   ```

**Usage:**

```bash
domain_investigator.sh -i <input file 1> -i <input file 2> -o <output file>

  -h, --help            Display this help message and exit.
  -i, --input-file      Path to a text file containing domain names (one per line).
  -o, --output-file     Path to the output CSV file (default: prints to console).
```

**Example:**

```bash
domain_investigator.sh -i domains.txt facebook.com -o output.csv
```

**Output:**

The script generates a CSV file with the following columns:

- Domain Name
- Registrant Organization
- Creation Date
- Registry Expiry Date
- Description

**Additional Notes:**

- The script uses a timeout mechanism to limit the time spent retrieving descriptions from websites.
- The script relies on parsing whois output and website HTML, which may not always be accurate or complete.
- For large lists of domains, it will take some time for example, a list with 1000 domain names, will take ~8 minutes.

**Dependencies:**

- `curl`: For making HTTP requests to retrieve website content.
- `dos2unix`: For converting text files with DOS-style line endings to Unix-style line endings.
- `whois`: For querying the WHOIS database to obtain domain registration information.
- `sqlite`: For joining csv files into one csv file.
- `perl`: For filtering output of http response.

**Limitations:**

- The accuracy of the retrieved information depends on the availability and reliability of the data sources.

**License:**

This script is released under the MIT License.

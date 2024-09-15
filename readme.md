**Improving the README for `domain_investigator.sh`**

Here's a revised README that incorporates feedback and provides additional clarity:

**domain_investigator.sh: A Domain Information Gathering Tool**

**Description:**

This script automates the process of gathering information about domain names, including descriptions, registrant organizations, creation dates, and registry expiry dates. It's designed for Debian 12 systems.

**Installation:**

1. **Prerequisites:** Ensure you have `curl`, `dos2unix`, and `whois` installed:
   ```bash
   sudo apt install curl dos2unix whois
   ```
2. **Save the Script:** Save the script content (including `get-desc.sh` and `get-reg.sh`) as `domain_investigator.sh`.
3. **Make Executable:** Grant the script execute permission:
   ```bash
   chmod +x domain_investigator.sh
   ```

**Usage:**

```bash
domain_investigator.sh [OPTIONS] [DOMAIN_NAMES]

  -h, --help            Display this help message and exit.
  -i, --input-file      Path to a text file containing domain names (one per line).
  -o, --output-file     Path to the output CSV file (default: prints to console).
```

**Example:**

```bash
domain_investigator.sh -i domains.txt
```

**Output:**

The script generates a CSV file with the following columns:

- Domain Name
- Description
- Registrant Organization
- Creation Date
- Registry Expiry Date

**Additional Notes:**

- The script uses a timeout mechanism to limit the time spent retrieving descriptions from websites.
- The script relies on parsing whois output and website HTML, which may not always be accurate or complete.
- For large lists of domains, consider increasing the sleep time between requests to avoid overwhelming servers.

**Dependencies:**

- `curl`: For making HTTP requests to retrieve website content.
- `dos2unix`: For converting text files with DOS-style line endings to Unix-style line endings.
- `whois`: For querying the WHOIS database to obtain domain registration information.

**Limitations:**

- The accuracy of the retrieved information depends on the availability and reliability of the data sources.
- The script may encounter errors if websites are inaccessible or if the HTML structure changes.

**Contributing:**

Contributions are welcome! Please submit pull requests or open issues on GitHub.

**License:**

This script is released under the MIT License.

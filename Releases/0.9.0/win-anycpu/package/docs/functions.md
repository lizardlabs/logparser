# SQL Function Reference

This page is the complete function catalog for the documented ULP runtime. It combines an exact generated inventory with categorized descriptions and examples. Always regenerate the inventory for a different build because SQLite compile options and registered extensions can change.

## About This Reference

- **ULP version:** run `ulp --version` for the installed build
- **SQLite version:** 3.32.1
- **Generation date:** 2026-09-02
- **Runtime signatures:** 395
- **Unique names:** 340
- **Generation method:** `ulp --list-functions --output file --format JSON`, backed by the runtime function catalog/`PRAGMA function_list`, then categorized by `PortableLogParser/tools/generate-function-reference.ps1`.
- **Machine-readable inventory:** [`reference/generated/sqlite-functions.json`](reference/generated/sqlite-functions.json)

A negative arity means a variable number of arguments. `scalar` returns one value per invocation; `aggregate` summarizes rows; `window` calculates across a window without collapsing rows. Compatibility status is reported by ULP, not inferred by this document.

A function appearing in this inventory does not override host permissions or safety restrictions. Web, MCP, and shell modes may reject an operation even when the SQLite runtime registers its function name. Review filesystem, network, dynamic-extension, process-execution, and write-capable functions before using them with untrusted queries or data.

## Contents

- [Function Quick Index](#function-quick-index)
- [Core and scalar functions](#core-and-scalar-functions)
- [Text functions](#text-functions)
- [Numeric and math functions](#numeric-and-math-functions)
- [Date and time functions](#date-and-time-functions)
- [Aggregate functions](#aggregate-functions)
- [Window functions](#window-functions)
- [JSON functions](#json-functions)
- [NULL and conditional functions](#null-and-conditional-functions)
- [Pattern-matching functions](#pattern-matching-functions)
- [Blob, binary, hash, and identifier functions](#blob-binary-hash-and-identifier-functions)
- [File-system functions](#file-system-functions)
- [Extension and specialized functions](#extension-and-specialized-functions)
- [Planned compatibility names](#planned-compatibility-names)
- [Compatibility Status](#compatibility-status)
- [Detailed Examples](#detailed-examples)

## Function Quick Index

### #

`__ulp_hashseq`, `__ulp_in_row_number`, `__ulp_out_row_number`, `__ulp_sequence`

### A

`abs`, `acos`, `acosh`, `add`, `asin`, `asinh`, `atan`, `atan2`, `atanh`, `atn2`, `avg`

### B

`base64_decode`, `base64_encode`, `bit_and`, `bit_not`, `bit_or`, `bit_shl`, `bit_shr`, `bit_xor`, `bm25`

### C

`ceil`, `ceiling`, `changes`, `char`, `charindex`, `coalesce`, `computer_name`, `concat`, `conv`, `cos`, `cosh`, `cot`, `coth`, `count`, `crc32`, `cume_dist`, `current_date`, `current_time`, `current_timestamp`

### D

`date`, `datetime`, `decimal`, `decimal_add`, `decimal_cmp`, `decimal_mul`, `decimal_sub`, `decimal_sum`, `decode`, `degrees`, `dehumanize_text`, `dense_rank`, `difference`, `directory_exists`, `div`, `dt_convert_timezone`, `dt_day_of_week`, `dt_from_unix_milliseconds`, `dt_from_unix_seconds`, `dt_from_utc`, `dt_is_weekend`, `dt_iso_week`, `dt_parse`, `dt_parseexact`, `dt_to_unix_milliseconds`, `dt_to_unix_seconds`, `dt_to_utc`, `dt_tostring`

### E

`editdist3`, `eval`, `exec`, `exp`, `exp10`, `extract_extension`, `extract_filename`, `extract_path`, `extract_prefix`, `extract_suffix`, `extract_token`, `extract_value`

### F

`file_exists`, `file_hash`, `file_hash_sha256`, `file_size`, `first_value`, `floor`, `from_camel_case`, `from_pascal_case`, `fts3_tokenizer`, `fts5`, `fts5_decode`, `fts5_decode_none`, `fts5_expr`, `fts5_expr_tcl`, `fts5_fold`, `fts5_isalnum`, `fts5_rowid`, `fts5_source_id`

### G

`glob`, `grok`, `group_concat`

### H

`hashmd5_file`, `HASHSEQ`, `hex`, `hex_to_asc`, `hex_to_hex16`, `hex_to_hex32`, `hex_to_hex8`, `hex_to_int`, `hex_to_print`, `highlight`, `humanize_bytes`, `humanize_number`, `humanize_ordinal`, `humanize_text`, `humanize_timespan`

### I

`ieee754`, `ieee754_exponent`, `ieee754_from_blob`, `ieee754_mantissa`, `ieee754_to_blob`, `ifnull`, `iif`, `IN_ROW_NUMBER`, `index_of`, `instr`, `int_to_ipv4`, `ipv4_to_int`, `is_null_or_whitespace`

### J

`json`, `json_array`, `json_array_length`, `json_extract`, `json_group_array`, `json_group_object`, `json_insert`, `json_object`, `json_patch`, `json_quote`, `json_remove`, `json_replace`, `json_set`, `json_type`, `json_valid`, `julianday`

### L

`lag`, `last_index_of`, `last_insert_rowid`, `last_rows_affected`, `last_value`, `lead`, `leftstr`, `length`, `levenshtein`, `like`, `likelihood`, `likely`, `load_extension`, `log`, `log10`, `lower`, `lower_quartile`, `lsmode`, `ltrim`

### M

`mask_sensitive_information`, `match`, `matchinfo`, `max`, `md5`, `median`, `min`, `mod`, `mode`, `mul`

### N

`next_char`, `nth_value`, `ntile`, `nullif`

### O

`offsets`, `optimize`, `ordinalize`, `OUT_ROW_NUMBER`

### P

`padc`, `padl`, `padr`, `path_change_extension`, `path_combine`, `path_is_rooted`, `percent_rank`, `percentile`, `percentile_25`, `percentile_75`, `percentile_90`, `percentile_95`, `percentile_99`, `percentile_cont`, `percentile_disc`, `pi`, `pluralize`, `power`, `prefix_length`, `printf`, `proper`

### Q

`qntfloor_to_digit`, `qntround_to_digit`, `quantize`, `quote`

### R

`radians`, `random`, `randomblob`, `rank`, `read_text_lines`, `readfile`, `regexp`, `regexp_like`, `regexp_replace`, `regexp_substr`, `replace`, `replace_chr`, `replace_if_not_null`, `replace_str`, `replicate`, `resolve_sid`, `reverse`, `reversedns`, `rightstr`, `rot13`, `round`, `row_number`, `rownum`, `rtreecheck`, `rtreedepth`, `rtreenode`, `rtrim`, `rx_get_group_value`, `rx_grok_to_regex`, `rx_is_match`, `rx_matches_count`, `rx_replace`, `rx_split`

### S

`SEQUENCE`, `sha1`, `sha256`, `sha384`, `sha512`, `sign`, `sin`, `singularize`, `sinh`, `snippet`, `soundex`, `spellfix1_editdist`, `spellfix1_phonehash`, `spellfix1_scriptcode`, `spellfix1_translit`, `split_part`, `sqlite_compileoption_get`, `sqlite_compileoption_used`, `sqlite_log`, `sqlite_source_id`, `sqlite_version`, `sqr`, `sqrroot`, `sqrt`, `square`, `stddev`, `stddev_pop`, `stddev_samp`, `stdev`, `strcat`, `strcnt`, `strfilter`, `strftime`, `strlen`, `strpart`, `strrepeat`, `strrev`, `sub`, `substr`, `sum`, `system_date`, `system_time`, `system_timestamp`, `system_utcoffset`

### T

`tan`, `tanh`, `time`, `to_absolute_path`, `to_camel_case`, `to_date`, `to_hex`, `to_int`, `to_kebab_case`, `to_localtime`, `to_lower_case`, `to_lowercase`, `to_pascal_case`, `to_real`, `to_snake_case`, `to_string`, `to_time`, `to_timestamp`, `to_title_case`, `to_upper_case`, `to_uppercase`, `to_utctime`, `tointeger`, `toreal`, `tosize`, `total`, `total_changes`, `trim`, `typeof`

### U

`unicode`, `unlikely`, `unzorder`, `upper`, `upper_quartile`, `urlescape`, `urlunescape`, `uuid`, `uuid_blob`, `uuid_str`

### V

`var_pop`, `var_samp`, `variance`

### W

`win32_error_description`, `writefile`

### X

`xml_append`, `xml_extract`, `xml_remove`, `xml_update`, `xml_valid`

### Z

`zeroblob`, `zipfile`, `zipfile_cds`, `zorder`

## Core and scalar functions

| Function | Arguments | Kind | Status | Description | Example |
| --- | ---: | --- | --- | --- | --- |
| `__ulp_hashseq` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `__ulp_in_row_number` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `__ulp_out_row_number` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `__ulp_sequence` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `add` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `bm25` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `changes` | 0 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `computer_name` | 0 | scalar | Compatible (platform-limited) | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `conv` | 3 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `decode` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `humanize_timespan` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `humanize_timespan` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `ieee754` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `ieee754` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `ieee754_exponent` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `ieee754_from_blob` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `ieee754_mantissa` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `ieee754_to_blob` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `index_of` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `int_to_ipv4` | 1 | scalar | Compatible (platform-limited) | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `ipv4_to_int` | 1 | scalar | Compatible (platform-limited) | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `is_null_or_whitespace` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `last_index_of` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `last_insert_rowid` | 0 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `last_rows_affected` | 0 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `levenshtein` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `lsmode` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `mask_sensitive_information` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `mask_sensitive_information` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `max` | variable | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `min` | variable | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `next_char` | 3 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `next_char` | 4 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `next_char` | 5 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `optimize` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `ordinalize` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `ordinalize` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `padc` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `padl` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `padr` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `path_change_extension` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `path_combine` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `path_is_rooted` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `prefix_length` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `proper` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `replace_chr` | 3 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `replace_str` | 3 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `resolve_sid` | 1 | scalar | Compatible (platform-limited) | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `resolve_sid` | 2 | scalar | Compatible (platform-limited) | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `reversedns` | 1 | scalar | Compatible (platform-limited) | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `rownum` | 0 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `rownum` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `sqlite_compileoption_get` | 1 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `sqlite_compileoption_used` | 1 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `sqlite_log` | 2 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `sqlite_source_id` | 0 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `sqlite_version` | 0 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `to_int` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `to_real` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `total_changes` | 0 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `typeof` | 1 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `win32_error_description` | 1 | scalar | Compatible (platform-limited) | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |

## Text functions

| Function | Arguments | Kind | Status | Description | Example |
| --- | ---: | --- | --- | --- | --- |
| `char` | variable | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `charindex` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `charindex` | 3 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `concat` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `dehumanize_text` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `extract_extension` | 1 | scalar | Compatible | Return a path extension using Microsoft Log Parser-compatible behavior. | `EXTRACT_EXTENSION(FullName)` |
| `extract_filename` | 1 | scalar | Compatible | Return a filename using Microsoft Log Parser-compatible behavior. | `EXTRACT_FILENAME(FullName)` |
| `extract_path` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `extract_prefix` | 3 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `extract_suffix` | 3 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `extract_token` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `extract_token` | 3 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `extract_value` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `extract_value` | 3 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `from_camel_case` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `from_pascal_case` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `humanize_ordinal` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `humanize_ordinal` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `humanize_text` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `instr` | 2 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `leftstr` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `length` | 1 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `lower` | 1 | scalar | SQLite built-in | Convert text to lowercase using SQLite behavior. | `lower(Level)` |
| `ltrim` | 1 | scalar | SQLite equivalent | SQLite function used as the equivalent of the corresponding Log Parser operation. | `â€”` |
| `ltrim` | 2 | scalar | SQLite equivalent | SQLite function used as the equivalent of the corresponding Log Parser operation. | `â€”` |
| `pluralize` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `printf` | variable | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `quote` | 1 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `replace` | 3 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `replicate` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `reverse` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `rightstr` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `rot13` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `rtrim` | 1 | scalar | SQLite equivalent | SQLite function used as the equivalent of the corresponding Log Parser operation. | `â€”` |
| `rtrim` | 2 | scalar | SQLite equivalent | SQLite function used as the equivalent of the corresponding Log Parser operation. | `â€”` |
| `split_part` | 3 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `strcat` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `strcnt` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `strfilter` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `strlen` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `strpart` | 3 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `strrepeat` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `strrev` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `substr` | 2 | scalar | Compatible | Return part of a string; ULP preserves the compatible registered overloads. | `SUBSTR(Message, 1, 80)` |
| `substr` | 3 | scalar | Compatible | Return part of a string; ULP preserves the compatible registered overloads. | `SUBSTR(Message, 1, 80)` |
| `to_camel_case` | 1 | scalar | ULP extension | Convert text to camelCase. | `TO_CAMEL_CASE('request id')` |
| `to_kebab_case` | 1 | scalar | ULP extension | Convert text to kebab-case. | `TO_KEBAB_CASE('RequestId')` |
| `to_lower_case` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `to_lower_case` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `to_lowercase` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `to_pascal_case` | 1 | scalar | ULP extension | Convert text to PascalCase. | `TO_PASCAL_CASE('request id')` |
| `to_snake_case` | 1 | scalar | ULP extension | Convert text to snake_case. | `TO_SNAKE_CASE('RequestId')` |
| `to_string` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `to_string` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `to_title_case` | 1 | scalar | ULP extension | Convert text to title case. | `â€”` |
| `to_upper_case` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `to_upper_case` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `to_uppercase` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `trim` | 1 | scalar | SQLite equivalent | Remove leading and trailing characters. | `TRIM(Message)` |
| `trim` | 2 | scalar | SQLite equivalent | Remove leading and trailing characters. | `TRIM(Message)` |
| `unicode` | 1 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `upper` | 1 | scalar | SQLite built-in | Convert text to uppercase using SQLite behavior. | `upper(Level)` |
| `urlescape` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `urlescape` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `urlunescape` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `urlunescape` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |

## Numeric and math functions

| Function | Arguments | Kind | Status | Description | Example |
| --- | ---: | --- | --- | --- | --- |
| `abs` | 1 | scalar | SQLite built-in | Return the absolute numeric value. | `ABS(-4)` |
| `acos` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `acosh` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `asin` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `asinh` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `atan` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `atan2` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `atanh` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `atn2` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `bit_and` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `bit_not` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `bit_or` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `bit_shl` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `bit_shr` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `bit_xor` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `ceil` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `ceiling` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `cos` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `cosh` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `cot` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `coth` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `decimal` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `decimal_add` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `decimal_cmp` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `decimal_mul` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `decimal_sub` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `decimal_sum` | 1 | aggregate/window | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `degrees` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `div` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `exp` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `exp10` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `floor` | 1 | scalar | SQLite equivalent | SQLite function used as the equivalent of the corresponding Log Parser operation. | `â€”` |
| `humanize_bytes` | 1 | scalar | ULP extension | Format a byte count as a readable size. | `HUMANIZE_BYTES(LengthInBytes)` |
| `humanize_bytes` | 2 | scalar | ULP extension | Format a byte count as a readable size. | `HUMANIZE_BYTES(LengthInBytes)` |
| `humanize_number` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `humanize_number` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `log` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `log10` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `mod` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `mul` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `pi` | 0 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `power` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `qntfloor_to_digit` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `qntround_to_digit` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `quantize` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `radians` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `random` | 0 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `randomblob` | 1 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `round` | 1 | scalar | SQLite equivalent | Round a number to the requested decimal precision. | `ROUND(value, 2)` |
| `round` | 2 | scalar | SQLite equivalent | Round a number to the requested decimal precision. | `ROUND(value, 2)` |
| `sign` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `sin` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `singularize` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `sinh` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `sqr` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `sqrroot` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `sqrt` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `square` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `sub` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `tan` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `tanh` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `tointeger` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `toreal` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `tosize` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |

## Date and time functions

| Function | Arguments | Kind | Status | Description | Example |
| --- | ---: | --- | --- | --- | --- |
| `current_date` | 0 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `current_time` | 0 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `current_timestamp` | 0 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `date` | variable | scalar | SQLite built-in | Return a normalized date using SQLite date modifiers. | `date(TimeCreated)` |
| `datetime` | variable | scalar | SQLite built-in | Return a normalized date and time using SQLite modifiers. | `datetime('now', '-24 hours')` |
| `dt_convert_timezone` | 3 | scalar | ULP extension | Convert a wall time between named or fixed-offset timezones. | `DT_CONVERT_TIMEZONE(value, 'UTC', '+02:00')` |
| `dt_day_of_week` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `dt_day_of_week` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `dt_from_unix_milliseconds` | 1 | scalar | ULP extension | Convert Unix milliseconds to an ISO timestamp. | `â€”` |
| `dt_from_unix_seconds` | 1 | scalar | ULP extension | Convert Unix seconds to an ISO timestamp. | `DT_FROM_UNIX_SECONDS(1700000000)` |
| `dt_from_utc` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `dt_is_weekend` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `dt_iso_week` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `dt_parse` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `dt_parse` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `dt_parseexact` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `dt_parseexact` | 3 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `dt_to_unix_milliseconds` | 1 | scalar | ULP extension | Convert a timestamp to Unix milliseconds. | `â€”` |
| `dt_to_unix_seconds` | 1 | scalar | ULP extension | Convert a timestamp to Unix seconds. | `â€”` |
| `dt_to_utc` | 1 | scalar | ULP extension | Normalize an instant or source-zone wall time to UTC. | `â€”` |
| `dt_to_utc` | 2 | scalar | ULP extension | Normalize an instant or source-zone wall time to UTC. | `â€”` |
| `dt_tostring` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `dt_tostring` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `dt_tostring` | 3 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `julianday` | variable | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `strftime` | variable | scalar | SQLite built-in | Format a SQLite date/time value. | `strftime('%Y-%m-%d', TimeCreated)` |
| `system_date` | 0 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `system_time` | 0 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `system_timestamp` | 0 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `system_utcoffset` | 0 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `time` | variable | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `to_date` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `to_localtime` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `to_time` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `to_timestamp` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `to_timestamp` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `to_utctime` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |

## Aggregate functions

| Function | Arguments | Kind | Status | Description | Example |
| --- | ---: | --- | --- | --- | --- |
| `avg` | 1 | aggregate/window | SQLite built-in | Return the average of non-null numeric values. | `AVG(DurationMs)` |
| `count` | 0 | aggregate/window | SQLite built-in | Count rows or non-null values. | `COUNT(*)` |
| `count` | 1 | aggregate/window | SQLite built-in | Count rows or non-null values. | `COUNT(*)` |
| `group_concat` | 1 | aggregate/window | SQLite built-in | Concatenate non-null values in an aggregate group. | `â€”` |
| `group_concat` | 2 | aggregate/window | SQLite built-in | Concatenate non-null values in an aggregate group. | `â€”` |
| `lower_quartile` | 1 | aggregate | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `max` | 1 | aggregate/window | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `median` | 1 | aggregate | ULP extension | Return the continuous median of non-null numeric values. | `MEDIAN(DurationMs)` |
| `min` | 1 | aggregate/window | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `mode` | 1 | aggregate | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `percentile` | 2 | aggregate | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `percentile_25` | 1 | aggregate | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `percentile_75` | 1 | aggregate | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `percentile_90` | 1 | aggregate | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `percentile_95` | 1 | aggregate | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `percentile_99` | 1 | aggregate | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `percentile_cont` | 2 | aggregate | ULP extension | Return a continuous interpolated percentile. | `PERCENTILE_CONT(DurationMs, 0.95)` |
| `percentile_disc` | 2 | aggregate | ULP extension | Return a percentile value observed in the input. | `â€”` |
| `stddev` | 1 | aggregate | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `stddev_pop` | 1 | aggregate | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `stddev_samp` | 1 | aggregate | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `stdev` | 1 | aggregate | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `sum` | 1 | aggregate/window | SQLite built-in | Return the sum of non-null numeric values. | `SUM(LengthInBytes)` |
| `total` | 1 | aggregate/window | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `upper_quartile` | 1 | aggregate | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `var_pop` | 1 | aggregate | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `var_samp` | 1 | aggregate | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `variance` | 1 | aggregate | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `zipfile` | variable | aggregate | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |

## Window functions

| Function | Arguments | Kind | Status | Description | Example |
| --- | ---: | --- | --- | --- | --- |
| `cume_dist` | 0 | window | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `dense_rank` | 0 | window | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `first_value` | 1 | window | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `lag` | 1 | window | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `lag` | 2 | window | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `lag` | 3 | window | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `last_value` | 1 | window | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `lead` | 1 | window | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `lead` | 2 | window | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `lead` | 3 | window | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `nth_value` | 2 | window | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `ntile` | 1 | window | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `percent_rank` | 0 | window | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `rank` | 0 | window | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `row_number` | 0 | window | SQLite built-in | Number rows within a window in result order. | `ROW_NUMBER() OVER (ORDER BY TimeCreated)` |

## JSON functions

| Function | Arguments | Kind | Status | Description | Example |
| --- | ---: | --- | --- | --- | --- |
| `json` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `json_array` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `json_array_length` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `json_array_length` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `json_extract` | variable | scalar | ULP extension | Extract one or more values from JSON paths. | `json_extract(Payload, '$.id')` |
| `json_group_array` | 1 | aggregate/window | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `json_group_object` | 2 | aggregate/window | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `json_insert` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `json_object` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `json_patch` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `json_quote` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `json_remove` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `json_replace` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `json_set` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `json_type` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `json_type` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `json_valid` | 1 | scalar | ULP extension | Return 1 when the input is valid JSON. | `json_valid(Payload)` |

## NULL and conditional functions

| Function | Arguments | Kind | Status | Description | Example |
| --- | ---: | --- | --- | --- | --- |
| `coalesce` | variable | scalar | SQLite equivalent | Return the first non-null argument. | `COALESCE(Message, '(missing)')` |
| `ifnull` | 2 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `iif` | 3 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `likelihood` | 2 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `likely` | 1 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `nullif` | 2 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `replace_if_not_null` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `unlikely` | 1 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |

## Pattern-matching functions

| Function | Arguments | Kind | Status | Description | Example |
| --- | ---: | --- | --- | --- | --- |
| `difference` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `editdist3` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `editdist3` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `editdist3` | 3 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `glob` | 2 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `grok` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `like` | 2 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `like` | 3 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `match` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `regexp` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `regexp_like` | 2 | scalar | ULP extension | Test whether text matches a regular expression. | `REGEXP_LIKE(Message, 'ERROR\|FATAL')` |
| `regexp_replace` | 3 | scalar | ULP extension | Replace regular-expression matches in text. | `â€”` |
| `regexp_substr` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `rx_get_group_value` | 3 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `rx_grok_to_regex` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `rx_is_match` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `rx_matches_count` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `rx_replace` | 3 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `rx_split` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `rx_split` | 3 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `soundex` | 1 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `spellfix1_editdist` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `spellfix1_phonehash` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `spellfix1_scriptcode` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `spellfix1_translit` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |

## Blob, binary, hash, and identifier functions

| Function | Arguments | Kind | Status | Description | Example |
| --- | ---: | --- | --- | --- | --- |
| `base64_decode` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `base64_encode` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `crc32` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `hex` | 1 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `hex_to_asc` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `hex_to_hex16` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `hex_to_hex16` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `hex_to_hex32` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `hex_to_hex32` | 2 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `hex_to_hex8` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `hex_to_int` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `hex_to_print` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `md5` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `sha1` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `sha256` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `sha384` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `sha512` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `to_hex` | 1 | scalar | Compatible | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `uuid` | 0 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `uuid_blob` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `uuid_str` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `zeroblob` | 1 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |

## File-system functions

| Function | Arguments | Kind | Status | Description | Example |
| --- | ---: | --- | --- | --- | --- |
| `directory_exists` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `file_exists` | 1 | scalar | ULP extension | Return 1 when the selected file exists, otherwise 0. | `FILE_EXISTS('C:\Logs\app.log')` |
| `file_hash` | 1 | scalar | ULP extension | Calculate a file digest with the selected algorithm. | `â€”` |
| `file_hash` | 2 | scalar | ULP extension | Calculate a file digest with the selected algorithm. | `â€”` |
| `file_hash_sha256` | 1 | scalar | ULP extension | Calculate a SHA-256 digest for a file. | `FILE_HASH_SHA256(FullName)` |
| `file_size` | 1 | scalar | ULP extension | Return the file length in bytes. | `FILE_SIZE(FullName)` |
| `hashmd5_file` | 1 | scalar | Compatible (platform-limited) | Microsoft Log Parser 2.2-compatible function. Check the compatibility notes for coercion and platform limits. | `â€”` |
| `read_text_lines` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `readfile` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `to_absolute_path` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `writefile` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |

## Extension and specialized functions

| Function | Arguments | Kind | Status | Description | Example |
| --- | ---: | --- | --- | --- | --- |
| `eval` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `eval` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `exec` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `fts3_tokenizer` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `fts3_tokenizer` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `fts5` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `fts5_decode` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `fts5_decode_none` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `fts5_expr` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `fts5_expr_tcl` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `fts5_fold` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `fts5_isalnum` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `fts5_rowid` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `fts5_source_id` | 0 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `highlight` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `load_extension` | 1 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `load_extension` | 2 | scalar | SQLite built-in | Function supplied by the SQLite runtime. | `â€”` |
| `matchinfo` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `matchinfo` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `offsets` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `rtreecheck` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `rtreedepth` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `rtreenode` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `snippet` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `unzorder` | 3 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `xml_append` | 3 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `xml_append` | 4 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `xml_extract` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `xml_extract` | 3 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `xml_remove` | 2 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `xml_update` | 3 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `xml_valid` | 1 | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `zipfile_cds` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |
| `zorder` | variable | scalar | ULP extension | Function or extension registered in the ULP SQLite runtime. | `â€”` |

## Planned compatibility names

| Function | Arguments | Kind | Status | Description | Example |
| --- | ---: | --- | --- | --- | --- |
| `HASHSEQ` | 1 | scalar | Planned (query state) | Reserved compatibility name; use only after the runtime reports an implemented status. | `â€”` |
| `IN_ROW_NUMBER` | 0 | scalar | Planned (query state) | Reserved compatibility name; use only after the runtime reports an implemented status. | `â€”` |
| `OUT_ROW_NUMBER` | 0 | scalar | Planned (query state) | Reserved compatibility name; use only after the runtime reports an implemented status. | `â€”` |
| `SEQUENCE` | 0 | scalar | Planned (query state) | Reserved compatibility name; use only after the runtime reports an implemented status. | `â€”` |
| `SEQUENCE` | 1 | scalar | Planned (query state) | Reserved compatibility name; use only after the runtime reports an implemented status. | `â€”` |

## Compatibility Status

| Status | Meaning |
| --- | --- |
| `SQLite built-in` | Supplied directly by the shipped SQLite runtime. |
| `SQLite equivalent` | SQLite spelling/behavior is the documented equivalent of a Microsoft Log Parser operation. |
| `Compatible` | ULP implements the documented Microsoft Log Parser 2.2 name and tested behavior. |
| `Compatible (platform-limited)` | Compatible behavior depends on Windows, DNS, accounts, files, or another platform service. |
| `ULP extension` | Additional function available in ULP; it is not presented as a Log Parser compatibility name. |
| `Planned (query state)` | Name is visible for compatibility planning but requires execution-state behavior; do not rely on it until its status changes. |

## Detailed Examples

### Text normalization

```sql
SELECT TO_PASCAL_CASE('request id') AS PascalName,
       TO_CAMEL_CASE('request id') AS CamelName,
       TO_SNAKE_CASE('RequestId') AS SnakeName,
       TO_KEBAB_CASE('RequestId') AS KebabName;
```

### Date/time conversion

```sql
SELECT DT_FROM_UNIX_SECONDS(1700000000) AS FromUnix,
       DT_TO_UTC('2026-08-25 10:30:00', '+02:00') AS UtcTime,
       DT_DAY_OF_WEEK('2026-08-25', 'en-US') AS Weekday;
```

### File statistics

```sql
SELECT FullName,
       LengthInBytes,
       HUMANIZE_BYTES(LengthInBytes, '0.##') AS ReadableSize,
       FILE_HASH_SHA256(FullName) AS SHA256
FROM files
WHERE FILE_EXISTS(FullName) = 1
ORDER BY LengthInBytes DESC
LIMIT 20;
```

Hash functions read content and can be expensive. Filter by metadata first and hash only bounded candidates.

### Percentiles for durations

```sql
SELECT MEDIAN(DurationMs) AS MedianMs,
       PERCENTILE_CONT(DurationMs, 0.95) AS P95Ms,
       PERCENTILE_DISC(DurationMs, 0.99) AS P99ObservedMs
FROM requests;
```

Use percentiles for ordered numeric measurements, not categorical values such as event names or severity labels.

### Microsoft Log Parser compatibility

```sql
SELECT EXTRACT_FILENAME(FullName) AS FileName,
       EXTRACT_EXTENSION(FullName) AS Extension,
       TO_INT(Status) AS StatusNumber,
       STRCAT(SourceName, Message) AS Combined
FROM records;
```

Use `LIMIT` instead of `TOP`, SQLite `CASE WHEN ... END` for conditions, and `||` or `STRCAT` for concatenation. Platform-limited functions can depend on DNS, Windows accounts, error-message resources, or file access.

## Related Documentation

- [SQLite Guide](sqlite-guide.md)
- [How-To Guide](how-to.md)
- [Generated reference artifacts](reference/generated/README.md)
- Run `ulp --list-functions` against the executable you are actually using.

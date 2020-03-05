# elastic-ingest-test-action

Tests a set of testcases against an elasticsearch pipeline definition.

## Inputs

### `elastic_version``

The version tag of elasticsearch to use. See <https://hub.docker.com/_/elasticsearch> for available version. Defaults to `7.5.2``

### `testdir``

Directory containing the pipeline and test definitions. Pipeline files are all file matching `pipe*.json`, tests are all files matching `test*.json``

## Outputs

### `testresults`

PASSED or FAILED, depending if the tests passed or failed. Will globally return "failed", if any single test fails.

## Example usage

```yaml
uses: actions/elastic-ingest-test-action@v1
with:
  elastic_version: 7.6.0
  testdir: ingest-tests
```

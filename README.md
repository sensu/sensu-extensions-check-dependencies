## Sensu::Extensions::CheckDependencies

This filter matches events when an event already exists, enabling the user to
reduce notification noise and only be notified for the “root cause” of a given
failure. Check dependencies can be defined in the check definition, using
dependencies, an array of checks (e.g. `check_app`) or Sensu client/check pairs
(e.g. `db-01/check_mysql`).

### Installation

This extension requires Sensu version >= 0.26.

On a Sensu server machine:

```
$ sudo sensu-install -e check-dependencies:1.0.0
```

Edit `/etc/sensu/conf.d/extensions.json` to load it:

```
{
  "extensions": {
    "check_dependencies": {
      "version": "1.0.0"
    }
  }
}
```

### Example Check/Handler Configuration

Specify a dependency on the `mysql` check:

``` javascript
{
  "checks": {
    "web_application_api": {
      "command": "check-http.rb -u https://localhost:8080/api/v1/health",
      "subscribers": [
        "web_application"
      ],
      "interval": 20,
      "dependencies": [
        "mysql"
      ]
    }
  }
}
```

... or specify a dependency on another client's `mysql` check:

``` javascript
{
  "checks": {
    "web_application_api": {
      "command": "check-http.rb -u https://localhost:8080/api/v1/health",
      "subscribers": [
        "web_application"
      ],
      "interval": 20,
      "dependencies": [
        "db-01/mysql"
      ]
    }
  }
}
```

Apply the `check_dependencies` filter to one or more handlers:

``` javascript
{
  "handlers": {
    "custom_mailer": {
      "type": "pipe",
      "command": "custom_mailer.rb",
      "filters": ["check_dependencies"]
    }
  }
}
```

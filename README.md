## Sensu::Extensions::CheckDependencies

This filter extension provides the Sensu Core built-in filter `check_dependencies`.

This filter matches events when an event already exists, enabling the user to
reduce notification noise and only be notified for the “root cause” of a given
failure. Check dependencies can be defined in the check definition, using
dependencies, an array of checks (e.g. `check_app`), Sensu client/check pairs
(e.g. `db-01/check_mysql`), or a subscription/check pair
(e.g. `subscription:mysql/check_mysql`).

[![Build Status](https://travis-ci.org/sensu-extensions/sensu-extensions-check-dependencies.svg?branch=master)](https://travis-ci.org/sensu-extensions/sensu-extensions-check-dependencies)

### Installation

This extension requires Sensu version >= 0.26 and is provided as a built-in 
filter in Sensu >= 0.29.

To manually install this extension on a Sensu server machine:

```
$ sudo sensu-install -e check-dependencies:1.0.1
```

Edit `/etc/sensu/conf.d/extensions.json` to load it:

```
{
  "extensions": {
    "check-dependencies": {
      "version": "1.0.1"
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

... or specify a dependency on any `mysql` check in the `mysql_nodes`
subscription:

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
        "subscription:mysql_nodes/mysql"
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

# gb-installer

This is installer script for [GitBucket](https://github.com/gitbucket/gitbucket) (v4.27.0).

Currently supported:

- CentOS 7 (1804.02 or later )
- PostgreSQL (9.4, 9.5, 9.6, 10 or later)
- Apache-Tomcat (8.5.32)

Run the command that appears:

```
$ curl -L https://raw.githubusercontent.com/mao172/gb-installer/master/install.sh | bash
```

For example:
```
$ curl -L https://raw.githubusercontent.com/mao172/gb-installer/master/install.sh | bash -s -- -p 10
```
will both install the GitBucket with PostgreSQL version 10 

WARN: Support to only when Lang=ja_JP.UTF-8.


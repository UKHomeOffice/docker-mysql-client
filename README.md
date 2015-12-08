# Docker ClamAV

Docker container for provisioning mysql databases.

## Getting Started

These instructions will cover how to start a container both in Docker and within a [Kubernetes](http://kubernetes.io/) cluster.

### Prerequisites

In order to run this container you'll need docker installed.

* [Windows](https://docs.docker.com/windows/started)
* [OS X](https://docs.docker.com/mac/started/)
* [Linux](https://docs.docker.com/linux/started/)

Optionally:

* A [Kubernetes](http://kubernetes.io/) cluster to enable Kubernetes api discovery of other nodes.

### Usage

The example below will run a mysql client container and create the database test with the user test_user:

```
docker run -i --rm=true \
       -e MYSQL_HOST=localhost \
       -e APP_DB_NAME=mydb \
       -e ROOT_PASS=secretpass \
       -e APP_DB_USER=myapp_user \
       -e APP_DB_PASS=myapppass \
       quay.io/ukhomeofficedigital/mysql-client:v0.1.2
```

To use with [Kubernetes](http://kubernetes.io/) see the [kubernetes examples](examples/kubernetes.md).


#### Environment Variables

The variables and the defaults are shown below.
By default, the container does not depend on [Kubernetes](http://kubernetes.io/). 

* `MYSQL_HOST=hostname` The host to connect to.
* `MYSQL_PORT=3306` The port to connect to.
* `ENABLE_SSL=FALSE` When set to TRUE, will ensure all users must connect using SSL using the Amazon RDS CA.
* `DEFAULT_PW=changeme` Supports changing a database provisioned root password from this value.
* `ROOT_PASS=`


## Contributing

Feel free to submit pull requests and issues. If it's a particularly large PR, you may wish to discuss
it in an issue first.

Please note that this project is released with a [Contributor Code of Conduct](code_of_conduct.md). 
By participating in this project you agree to abide by its terms.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the 
[tags on this repository](https://github.com/UKHomeOffice/docker-mysql-client/tags).

## Authors

* **Lewis Marshall** - *Initial work* - [Lewis Marshall](https://github.com/LewisMarshall)

See also the list of [contributors](https://github.com/UKHomeOffice/docker-mysql-client/contributors) who
participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

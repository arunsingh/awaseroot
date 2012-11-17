# == Class: nagios3
#
# This module manages Nagios.
# Work in progress... Only localhost monitoring at the moment.
#
# Tested platforms:
#  - Ubuntu 12.10
#
# === Parameters
#
# $version = [ 'installed', 'latest' ]
# 
# === Examples
#
# class { 'nagios3':
#   version => 'latest',
# }
#
# === Authors
#
# Henri Siponen <siponenhenri@gmail.com>
#
class nagios3($version='latest') {

  case $::operatingsystem {
    debian, ubuntu: {
      $ok = true
    }
    centos, redhat, oel, linux: {
      fail("This module is not yet tested or supported on ${operatingsystem}")      
    }
    default: {
      fail("This module is not supported on ${operatingsystem}")
    }
  }

  if ($ok) {

    Package { ensure => $version, }
    File { owner => 'root', group => 'root', mode => '0644', }

    package { 'libapache2-mod-php5': }
    package { 'libgd2-xpm-dev': }
    package { 'apache2': }

    service { 'apache2':
      ensure  => 'running',
      enable  => true,
      require => Package['apache2'],
    }

    package { 'nagios3': require => Package['apache2'] }

    service { 'nagios3':
      ensure  => 'running',
      enable  => true,
      require => Package['nagios3'],
    }

    file { '/etc/nagios3/nagios.cfg':
      ensure  => present,
      source  => 'puppet:///modules/nagios3/nagios.cfg',
      require => Package['nagios3'],
      notify  => Service['nagios3'],
    }

    file { '/etc/nagios3/commands.cfg':
      ensure  => present,
      source  => 'puppet:///modules/nagios3/commands.cfg',
      require => Package['nagios3'],
      notify  => Service['nagios3'],
    }

    file { '/etc/nagios3/objects':
      ensure  => directory,
      mode   => 0755,
      require => Package['nagios3'],
    }

    file { '/etc/nagios3/htpasswd.users': 
      ensure  => present,
      source  => 'puppet:///modules/nagios3/htpasswd.users',
      require => Package['nagios3'],
      notify  => Service['nagios3'],
    }
  }
}
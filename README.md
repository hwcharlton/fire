# Automated Remote Development Environment Creation

The name of this project is still undecided.

## Project Goals

Make the creation of a temporary (e.g., a few hours) remote development environment quick, easy, and flexible.

For example: A user should be able to easily create an ssh-able instance and specify the development environment (editor, configuration files, etc.), source code to edit (e.g., a git repo), and machine specs (ec2 instance type).  When the task is finished, the user should be able to terminate the server and only be charged for the hours used.

## How It Should Work

Currently, this is being developed to work on AWS exclusively.

A 'base' ec2 instance is created along with a properly set up (non-default) VPC in any region. A user who logs into the 'base' instance via ssh can then, with a single CLI command, launch and ssh into a 'task' instance customized for the development task that the user wants to work on. Once the user is finished with the task, the 'task' instance can easily be terminated. Automatic termination (e.g., after no connections after a period of time) should also be configurable.

'Base' instances should be customizable and easy to launch/terminate.

What a 'base' instance includes:

* VPC with public subnet and proper tags (can be automatically generated in arbitrary region)
* Installation of this git repository's command line tool
  * Source is in POSIX shell, so any Unix machine should be capable of running it.
* Installation of JMESPath 'jp' command line tool

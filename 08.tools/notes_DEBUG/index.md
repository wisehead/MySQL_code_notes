---
title: MySQL :: MySQL 5.7 Reference Manual :: 5.8.3 The DBUG Package
category: default
tags: 
  - dev.mysql.com
created_at: 2020-08-12 17:25:37
original_url: https://dev.mysql.com/doc/refman/5.7/en/dbug-package.html
---


# MySQL :: MySQL 5.7 Reference Manual :: 5.8.3 The DBUG Package

version 5.7

[MySQL 5.7 Reference Manual](https://dev.mysql.com/doc/refman/5.7/en/)  /  ...  /  The DBUG Package

### 5.8.3 The DBUG Package

The MySQL server and most MySQL clients are compiled with the DBUG package originally created by Fred Fish. When you have configured MySQL for debugging, this package makes it possible to get a trace file of what the program is doing. See [Section 5.8.1.2, “Creating Trace Files”](https://dev.mysql.com/doc/refman/5.7/en/making-trace-files.html "5.8.1.2 Creating Trace Files").

This section summarizes the argument values that you can specify in debug options on the command line for MySQL programs that have been built with debugging support.

The DBUG package can be used by invoking a program with the ``--debug[=_`debug_options`_]`` or ``-# [_`debug_options`_]`` option. If you specify the `--debug` or `-#` option without a _`debug_options`_ value, most MySQL programs use a default value. The server default is `d:t:i:o,/tmp/mysqld.trace` on Unix and `d:t:i:O,\mysqld.trace` on Windows. The effect of this default is:

*   `d`: Enable output for all debug macros
    
*   `t`: Trace function calls and exits
    
*   `i`: Add PID to output lines
    
*   `o,/tmp/mysqld.trace`, `O,\mysqld.trace`: Set the debug output file.
    

Most client programs use a default _`debug_options`_ value of ``d:t:o,/tmp/_`program_name`_.trace``, regardless of platform.

Here are some example debug control strings as they might be specified on a shell command line:

```ini
--debug=d:t
--debug=d:f,main,subr1:F:L:t,20
--debug=d,input,output,files:n
--debug=d:t:i:O,\\mysqld.trace
```

For [**mysqld**](https://dev.mysql.com/doc/refman/5.7/en/mysqld.html "4.3.1 mysqld — The MySQL Server"), it is also possible to change DBUG settings at runtime by setting the [`debug`](https://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html#sysvar_debug) system variable. This variable has global and session values:

```sql
mysql> SET GLOBAL debug = 'debug_options';
mysql> SET SESSION debug = 'debug_options';
```

Changing the global [`debug`](https://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html#sysvar_debug) value requires privileges sufficient to set global system variables. Changing the session [`debug`](https://dev.mysql.com/doc/refman/5.7/en/server-system-variables.html#sysvar_debug) value requires privileges sufficient to set restricted session system variables. See [Section 5.1.8.1, “System Variable Privileges”](https://dev.mysql.com/doc/refman/5.7/en/system-variable-privileges.html "5.1.8.1 System Variable Privileges").

The _`debug_options`_ value is a sequence of colon-separated fields:

```simple
field_1:field_2:...:field_N
```

Each field within the value consists of a mandatory flag character, optionally preceded by a `+` or `-` character, and optionally followed by a comma-separated list of modifiers:

```simple
[+|-]flag[,modifier,modifier,...,modifier]
```

The following table describes the permitted flag characters. Unrecognized flag characters are silently ignored.

| 
Flag

 | 

Description

 |
| --- | --- |
| 

`d`

 | 

Enable output from DBUG\__`XXX`_ macros for the current state. May be followed by a list of keywords, which enables output only for the DBUG macros with that keyword. An empty list of keywords enables output for all macros.

In MySQL, common debug macro keywords to enable are `enter`, `exit`, `error`, `warning`, `info`, and `loop`.

 |
| 

`D`

 | 

Delay after each debugger output line. The argument is the delay, in tenths of seconds, subject to machine capabilities. For example, `D,20` specifies a delay of two seconds.

 |
| 

`f`

 | 

Limit debugging, tracing, and profiling to the list of named functions. An empty list enables all functions. The appropriate `d` or `t` flags must still be given; this flag only limits their actions if they are enabled.

 |
| 

`F`

 | 

Identify the source file name for each line of debug or trace output.

 |
| 

`i`

 | 

Identify the process with the PID or thread ID for each line of debug or trace output.

 |
| 

`L`

 | 

Identify the source file line number for each line of debug or trace output.

 |
| 

`n`

 | 

Print the current function nesting depth for each line of debug or trace output.

 |
| 

`N`

 | 

Number each line of debug output.

 |
| 

`o`

 | 

Redirect the debugger output stream to the specified file. The default output is `stderr`.

 |
| 

`O`

 | 

Like `o`, but the file is really flushed between each write. When needed, the file is closed and reopened between each write.

 |
| 

`p`

 | 

Limit debugger actions to specified processes. A process must be identified with the `DBUG_PROCESS` macro and match one in the list for debugger actions to occur.

 |
| 

`P`

 | 

Print the current process name for each line of debug or trace output.

 |
| 

`r`

 | 

When pushing a new state, do not inherit the previous state's function nesting level. Useful when the output is to start at the left margin.

 |
| 

`S`

 | 

Do function `_sanity(_file_,_line_)` at each debugged function until `_sanity()` returns something that differs from 0.

 |
| 

`t`

 | 

Enable function call/exit trace lines. May be followed by a list (containing only one modifier) giving a numeric maximum trace level, beyond which no output occurs for either debugging or tracing macros. The default is a compile time option.

 |

The leading `+` or `-` character and trailing list of modifiers are used for flag characters such as `d` or `f` that can enable a debug operation for all applicable modifiers or just some of them:

*   With no leading `+` or `-`, the flag value is set to exactly the modifier list as given.
    
*   With a leading `+` or `-`, the modifiers in the list are added to or subtracted from the current modifier list.
    

The following examples show how this works for the `d` flag. An empty `d` list enabled output for all debug macros. A nonempty list enables output only for the macro keywords in the list.

These statements set the `d` value to the modifier list as given:

```sql
mysql> SET debug = 'd';
mysql> SELECT @@debug;
+---------+
| @@debug |
+---------+
| d       |
+---------+
mysql> SET debug = 'd,error,warning';
mysql> SELECT @@debug;
+-----------------+
| @@debug         |
+-----------------+
| d,error,warning |
+-----------------+
```

A leading `+` or `-` adds to or subtracts from the current `d` value:

```sql
mysql> SET debug = '+d,loop';
mysql> SELECT @@debug;
+----------------------+
| @@debug              |
+----------------------+
| d,error,warning,loop |
+----------------------+
mysql> SET debug = '-d,error,loop';
mysql> SELECT @@debug;
+-----------+
| @@debug   |
+-----------+
| d,warning |
+-----------+
```

Adding to “all macros enabled” results in no change:

```sql
mysql> SET debug = 'd';
mysql> SELECT @@debug;
+---------+
| @@debug |
+---------+
| d       |
+---------+
mysql> SET debug = '+d,loop';
mysql> SELECT @@debug;
+---------+
| @@debug |
+---------+
| d       |
+---------+
```

Disabling all enabled macros disables the `d` flag entirely:

```sql
mysql> SET debug = 'd,error,loop';
mysql> SELECT @@debug;
+--------------+
| @@debug      |
+--------------+
| d,error,loop |
+--------------+
mysql> SET debug = '-d,error,loop';
mysql> SELECT @@debug;
+---------+
| @@debug |
+---------+
|         |
+---------+
```

  

[PREV](https://dev.mysql.com/doc/refman/5.7/en/debugging-client.html "Previous: Debugging a MySQL Client")   [HOME](https://dev.mysql.com/doc/refman/5.7/en/index.html "Start")   [UP](https://dev.mysql.com/doc/refman/5.7/en/debugging-mysql.html "Up: Debugging MySQL")   [NEXT](https://dev.mysql.com/doc/refman/5.7/en/dba-dtrace-server.html "Next: Tracing mysqld Using DTrace")

---------------------------------------------------


原网址: [访问](https://dev.mysql.com/doc/refman/5.7/en/dbug-package.html)

创建于: 2020-08-12 17:25:37

目录: default

标签: `dev.mysql.com`


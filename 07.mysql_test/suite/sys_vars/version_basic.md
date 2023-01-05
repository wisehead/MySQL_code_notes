#1.version_basic

```
version_basic
####################################################################
#   Displaying default value                                       #
####################################################################
--SELECT COUNT(@@GLOBAL.version);
####################################################################
#   Check if Value can set                                         #
####################################################################
-- //--error ER_INCORRECT_GLOBAL_LOCAL_VAR
-- SET @@GLOBAL.version=1;
-- //--echo Expected error 'Read only variable'
#################################################################
# Check if the value in GLOBAL Table matches value in variable  #
#################################################################
--SELECT @@GLOBAL.version = VARIABLE_VALUE FROM INFORMATION_SCHEMA.GLOBAL_VARIABLES WHERE VARIABLE_NAME='version';
################################################################################
#  Check if accessing variable with and without GLOBAL point to same variable  #
################################################################################
--SELECT @@version = @@GLOBAL.version;
################################################################################
#   Check if version can be accessed with and without @@ sign                  #
################################################################################
--//--Error ER_INCORRECT_GLOBAL_LOCAL_VAR
--SELECT COUNT(@@local.version);
--//--echo Expected error 'Variable is a GLOBAL variable'

--//--Error ER_INCORRECT_GLOBAL_LOCAL_VAR
--SELECT COUNT(@@SESSION.version);
--//--echo Expected error 'Variable is a GLOBAL variable'
```
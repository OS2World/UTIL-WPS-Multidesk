/* rexx - test for AuxFuncs.dll */

rc = rxFuncAdd( 'sysLoadFuncs', 'rexxUtil', 'SysLoadFuncs' )
call sysLoadFuncs

rc = rxFuncAdd( 'AFLoadFuncs', 'AuxFuncs', 'AFLoadFuncs' )
if rc \= 0 then do
	say 'Cannot (re-)register AuxFuncs functions, may be registered already.'
	say 'Now trying to drop and reregister them...'
	call AFDropFuncs
	say 'AuxFuncs dropped.'
	rc = rxFuncAdd( 'AFLoadFuncs', 'AuxFuncs', 'AFLoadFuncs' )
	if rc \= 0 then
		say 'Failed again registering AuxFuncs ?!?!?!?'
	else do
		call AFLoadFuncs
		say 'AuxFuncs registered.'
	end
end; else
	call AFLoadFuncs

say

/* Provo AFGetBootDrive */
say 'Boot drive: ' AFGetBootDrive()
say

/* Provo AFGetObjectHandle */
say '<WP_DESKTOP> object handle: ' AFGetObjectHandle('<WP_DESKTOP>')
say

/* Provo AFGetAbsPath */
say 'Absolute path of ".\functest.cmd", with check: '
say '  ' AFGetAbsPath('.\functest.cmd', 'C')
say

say 'Absolute path of ".\pippo\pluto\dummy.txt", without check: '
say '  ' AFGetAbsPath('.\pippo\pluto\dummy.txt', 'N')
say

say 'Absolute path of ".\pippo\pluto\dummy.txt", with check: '
say '  ' AFGetAbsPath('.\pippo\pluto\dummy.txt', 'C')
say

/* Provo AFDelTree */
say 'Generating a dummy tree of directories...'
'@md DummyTree'
'@md DummyTree\1'
'@md DummyTree\2'
'@md DummyTree\3'
'@md DummyTree\1\11'
'@md DummyTree\1\12'
'@copy functest.cmd DummyTree\1\11'
say 'Finished:'
'@dir /AD'
'@pause'
say 'Now removing the tree:'
say AFDelTree('DummyTree')
say

say 'End of test'

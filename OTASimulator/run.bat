for /l %%x in (1, 1, 20) do (
	set /A num=%1+%%x
	set arg=in%num%
	start /B python OTASimulator.py testJSon.json in%%x instructions.txt
)
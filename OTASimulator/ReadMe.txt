OTAV2 Simulator

Installation Prerequisites:
- Python3
- Python MQTT library: pip install paho-mqtt
- Google Protocol Buffer Python Runtime library: pip install protobuf
- Mosquitto broker

Simulator Setup:

"mosquitto -v -c mosquittoTest.conf" to run broker with correct
listeners

run "py OTASimulator.py *testJSon.json* in#" in a command prompt to
send specific messages where # is the vehicle id number
or run.bat to run a few premade tests

run "py OTASimulator.py *testJSon.json* in# instructions.txt" in a command prompt to
execute commands found in the .txt file

run "py OTASimulator.py *testJSon.json* out" in a different command
prompt to simulate the fixed end

Note: fixed end simulator must be running before run.bat is executed.

The testJSon.json has the definition of a fixed inbound message header 
as well as the definitions of the different inbound/outbound messages the simulator can send.

Vehicle Simulator:

The vehicle simulator uses regular expressions to match commands and can simulate the following commands:
1. Send inbound message through mqtt broker to fixed end simulator. Parameters of inbound message can be changed.
	- Regex: "^Send (\d+|[a-zA-Z]+)(\s*[a-zA-Z]+=\d+\s*)*$"
	- Example valid commands: Send 1, Send CannedDataMsg, Send 1 DataMessageID=10 TimeStamp=200
	- Notes: Messages can be sent using the message id or the message name. Overriding parameters is optional
		  and may not contain spaces between the param name and param value (see regex). Only inbound messages
		  defined in the .json are able to be sent.
2. Simulate delay in seconds.
	- Regex: "^Delay (\d+)$"
	- Example valid commands: Delay 10, Delay 1
3. Encapsulate instructions in labels. Allows user to store instructions.
	- Regex: "^([a-zA-Z]+):$"
	- Example valid commands: A:, B:, Label:
4. End label.
	- Regex: "^End ([a-zA-Z]+)$"
	- Example valid commands: End A, End B, End Label
	- Note: label must already have been defined using a command from (3)
5. Loop. Allows user to execute commands stored in a label multiple times.
	- Regex: "^Loop ([a-zA-Z]+) (\d+)$"
	- Example valid commands: Loop A 2, Loop B 10, Loop Label 5
	- Note: the second argument must be a label that has been defined already and ended using (4).
		  the third argument is the number of times the label is executed.
6. Quit. Closes the connection to the mqtt broker and exits the vehicle simulator.
	- Example valid command: quit

Example usage of all commands:
	A:
	Send VehicleAlive FallbackVoiceChannel=1
	Delay 1
	Send VehicleLogon
	Send CannedDataMsg DataMessageID=10
	Send VehicleLogoff
	End A
	Loop A 5
	quit

This example creates a label, storing instructions to send 4 different messages. Then, that label is executed 5 times. 
A total of 20 messages will end up being sent.

Fixed End Simulator:

Messages are recieved by the out command screen (fixed end simulator) and the expected
responses are sent back to the vehicle. Output is stored in the logs folder sorted by time and vehicle id

Configuration Ranges
keepAlive: 0 - 65535
maxPayload: 1 - 268435455

GUI Simulator:

py OTASimulator.py *testJSon.json* graphical

The GUI Simulator has the capability of simulating both vehicles and fixed end systems. 
If the Inbound checkbox is checked, it is simulating vehicles and if unchecked, it is simulating the fixed end.
Vehicle GUI Simulator:
	- The vehicle ID can be changed but it must be 4 digits long
	- Use the dropdown to select messages to send and optionally change the parameters using the set parameters button
	- Vehicle output will be sent to the GUI as well as written to the logs folder
Fixed End GUI Simulator:
	- When using the fixed end, vehicle must have an id other than 1000. This is because the default vehicle id for the simulator is 1000
		which will create conflicts with the broker; because no two same client names can be connected to the broker simultaneously
	- In order to sent messages to vehicles, vehicles must first have sent a message to the fixed end. 
		If not, the fixed end simulator is unable to recognize which vehicles are "connected" to it.
	- Sending messages manually will send to all vehicles that have previously sent a message to the fixed end.
		In order to reset this, switch to the vehicle simulator and switch back to fixed end using the Inbound checkbox.
	- Use the dropdown to select messages to send and optionally change the parameters using the set parameters button

Remote distribution test:
We created a remote connection to a test IVU and put the broker on that machine.
One laptop had the fixed end simulator connected to that broker and another laptop had a vehicle simulator connected to the broker.
We were able to sent OTA messages through the broker on the test IVU between laptops.
In order to establish the connection between simulator and mqtt broker, we had to disable firewalls on both machines.
We also tested multiple vehicle(~50) simulators sending messages to a fixed end simulator which was successful but seemed like it was throttled by the hardware.
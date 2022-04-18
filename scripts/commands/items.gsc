#include scripts\_utility;

cmd(args, prefix)
{
	self scripts\_items::printItems();
	self respond("^2List of items dumped to console.");
}

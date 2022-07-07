#include scripts\_utility;

// Algorithm by Rich Felker @ https://stackoverflow.com/a/21593949
unixToDate(unix)
{
	if (!isDefined(unix)) return undefined;

	// 2000-03-01 (mod 400 year, immediately after feb29)
	LEAPOCH = (946684800 + 86400 * (31 + 29));

	DAYS_PER_400Y = (365 * 400 + 97);
	DAYS_PER_100Y = (365 * 100 + 24);
	DAYS_PER_4Y   = (365 *   4 +  1);

	days_in_month = [];
	days_in_month[0] = 31;
	days_in_month[1] = 30;
	days_in_month[2] = 31;
	days_in_month[3] = 30;
	days_in_month[4] = 31;
	days_in_month[5] = 31;
	days_in_month[6] = 30;
	days_in_month[7] = 31;
	days_in_month[8] = 30;
	days_in_month[9] = 31;
	days_in_month[10] = 31;
	days_in_month[11] = 29;

	secs = int(unix) - LEAPOCH;
	days = int(secs / 86400);
	remsecs = secs % 86400;
	if (remsecs < 0)
	{
		remsecs += 86400;
		days--;
	}

	wday = (3 + days) % 7;
	if (wday < 0) wday += 7;

	qc_cycles = int(days / DAYS_PER_400Y);
	remdays = days % DAYS_PER_400Y;
	if (remdays < 0)
	{
		remdays += DAYS_PER_400Y;
		qc_cycles--;
	}

	c_cycles = int(remdays / DAYS_PER_100Y);
	if (c_cycles == 4) c_cycles--;
	remdays -= c_cycles * DAYS_PER_100Y;

	q_cycles = int(remdays / DAYS_PER_4Y);
	if (q_cycles == 25) q_cycles--;
	remdays -= q_cycles * DAYS_PER_4Y;

	remyears = int(remdays / 365);
	if (remyears == 4) remyears--;
	remdays -= remyears * 365;

	leap = !remyears && (q_cycles || !c_cycles);
	yday = remdays + 31 + 28 + leap;
	if (yday >= 365 + leap) yday -= 365 + leap;

	years = remyears + 4 * q_cycles + 100 * c_cycles + 400 * qc_cycles;

	months = 0;
	while (days_in_month[months] <= remdays)
	{
		remdays -= days_in_month[months];
		months++;
	}

	if (months >= 10)
	{
		months -= 12;
		years++;
	}

	date = spawnStruct();
	date.year = years + 2000;
	date.month = months + 2 + 1;
	date.day = remdays + 1;
	date.weekday = wday;
	date.yearday = yday + 1;

	date.hour = int(remsecs / 3600);
	date.minute = int(remsecs / 60) % 60;
	date.second = remsecs % 60;

	return date;
}

unixToRelativeTimeString(unix)
{
	if (!isDefined(unix)) return undefined;

	diff = (getSystemTime() - int(unix));
	inFuture = (diff < 0);
	diff = abs(diff);

	str = "";

	if (diff == 0)
	{
		return "just now";
	}
	else if (diff < 60)
	{
		s = int(diff);
		str = s + " second" + ternary(s != 1, "s", "");
	}
	else if (diff < 3600)
	{
		m = int(diff / 60);
		str = m + " minute" + ternary(m != 1, "s", "");
	}
	else if (diff < 86400)
	{
		h = int(diff / 3600);
		str = h + " hour" + ternary(h != 1, "s", "");
	}
	else if (diff < 604800)
	{
		d = int(diff / 86400);
		str = d + " day" + ternary(d != 1, "s", "");
	}
	else if (diff < 2629743)
	{
		w = int(diff / 604800);
		str = w + " week" + ternary(w != 1, "s", "");
	}
	else if (diff < 31556926)
	{
		m = int(diff / 2629743);
		str = m + " month" + ternary(m != 1, "s", "");
	}
	else
	{
		y = int(diff / 31556926);
		str = y + " year" + ternary(y != 1, "s", "");
	}

	str = ternary(inFuture, "in ", "") + str + ternary(!inFuture, " ago", "");

	return str;
}

dateToISO(date)
{
	return ""
		+ stringPadStart(date.year, 4, "0") + "-"
		+ stringPadStart(date.month, 2, "0") + "-"
		+ stringPadStart(date.day, 2, "0") + "T"
		+ stringPadStart(date.hour, 2, "0") + ":"
		+ stringPadStart(date.minute, 2, "0") + ":"
		+ stringPadStart(date.second, 2, "0") + "Z";
}

getSystemTimeISO()
{
	return dateToISO(unixToDate(getSystemTime()));
}

# working with dates

# lubridate
#Date: Collection date change to lubridate format
df$Date <- lubridate::ymd(df$Date)
# Month
df$Month <- month(df$Date)
#Year
df$Year <- year(df$Date)
#Month_Year_floor as date rounded to first day of month
df$Month_Year_floor <- lubridate::floor_date(df$Date, unit="month")
#Month_Year_letter as words/characters- three letter month and two-digit year
df$Month_Year_letter <-format(df$Month_Year_floor, format = "%b %y")
df$Month_Year_letter <- as.factor(df$Month_Year_letter)

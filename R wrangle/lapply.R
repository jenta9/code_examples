# wrangling using lapply

# Change variable type
cols <- c("Var1", "Var2", "Var3")
df[cols] <- lapply(df[cols], factor)



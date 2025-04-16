# Calculate route counts
route_counts <- play_data |>
  count(routeRan, sort=TRUE)
# Make bar plot
ggplot(data=route_counts, aes(x=reorder(routeRan,-n),y=n)) +
  geom_bar(stat="identity") +
  xlab("Route Run") +
  ylab("Number of times run")
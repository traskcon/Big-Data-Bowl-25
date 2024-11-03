import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import plotly.express as px

week1_tracking = pd.read_csv("tracking_week_1.csv")

def show_play(play_df):
    los = play_df[(play_df["displayName"] == "football") & (play_df["frameType"] == "SNAP")]["x"]
    ani = px.scatter(play_df, x="x", y="y", animation_frame="frameId", animation_group="displayName", color="club", hover_name="displayName",
                    range_x=[0,120], range_y=[0,max(sample_play["y"])], size="size", size_max=8)
    ani.show()

sample_game = week1_tracking[week1_tracking["gameId"] == 2022091107]
sample_play = sample_game[sample_game["playId"] == 2200]

sample_play["size"] = 1.0
sample_play.loc[sample_play["displayName"] == "football", "size"] = 0.2

show_play(sample_play)
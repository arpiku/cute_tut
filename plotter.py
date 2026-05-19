import pandas as pd
import plotly.graph_objects as go

df = pd.read_csv("layout.csv")

fig = go.Figure(data=[go.Scatter3d(
    x=df['mode0'],
    y=df['mode1'],
    z=df['mode2'],
    mode='markers',
    marker=dict(
        size=5,
        color=df['index'],          # colour by linear index
        colorscale='Viridis',
        colorbar=dict(title='Index'),
        opacity=0.8,
    ),
    text=df['index'],               # hover shows the index value
    hovertemplate=(
        'mode0: %{x}<br>'
        'mode1: %{y}<br>'
        'mode2: %{z}<br>'
        'index: %{text}<extra></extra>'
    ),
)])

fig.update_layout(
    scene=dict(
        xaxis_title='Mode 0',
        yaxis_title='Mode 1',
        zaxis_title='Mode 2',
    ),
    title='CuTe Layout: (8,8,8):(1,8,64)',
)

fig.show()

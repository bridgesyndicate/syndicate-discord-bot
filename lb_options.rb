def lb_options
  [
    {
      name: 'sort',
      description: 'Value to sort the leaderboard by',
      type: 3,
      choices: [
        {
          name: "elo",
          value: "elo"
        },
        {
          name: "wins",
          value: "wins"
        },
        {
          name: "losses",
          value: "losses"
        },
        {
          name: "ties",
          value: "ties"
        }
      ],
      required: false
    },
    {
      name: 'page',
      description: 'Page of the leaderboard',
      type: 4,
      required: false
    },
    {
      name: 'season',
      description: 'Season of the leaderboard',
      type: 3,
      required: false
    }
  ]
end

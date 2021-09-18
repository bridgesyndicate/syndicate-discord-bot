def game_options
  [
    {
      name: 'goals',
      description: 'Number of goals to win',
      type: 4,
      required: false,
      choices: [
        {
          name: "1",
          value: 1
        },
        {
          name: "2",
          value: 2
        },
        {
          name: "3",
          value: 3
        },
        {
          name: "4",
          value: 4
        },
        {
          name: "5",
          value: 5
        }
      ]
    },
    {
      name: 'length',
      description: 'Length of game in minutes',
      type: 4,
      required: false,
      choices: [
        {
          name: "5",
          value: 300
        },
        {
          name: "10",
          value: 600
        },
        {
          name: "15",
          value: 900
        },
      ]
    }
  ]
end

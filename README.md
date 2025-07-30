# Chain Blocks

##  Take-Home Assessment instructions

This Take Home Test is designed to give you an opportunity to show prospective team mates how you approach problem solving, your coding style, and how you handle new problem domains.

- **Don’t spend more than 3hrs on this task.** You do not need any specific Blockchain knowledge to complete the task.
- We do not want you spending days on this assignment. A qualified candidate should be able to deliver something that meets the requirements within the above time frame.
- Anything you've not been able to complete can be noted in the README so that the team can understand what you have prioritized and what you've chosen to defer.

### Product Brief

We want to see code that reflects the level you are applying for. For example, if you are interviewing as a Senior Engineer, we expect to see Senior Engineer level code, thinking, and attention to detail.

Create a block explorer app for a simulated NEAR blockchain. You should create a new Rails app, and make appropriate database tables, models, views etc as needed to meet the requirements.

We have created a simulated NEAR blockchain API endpoint that you should use here:

`https://4816b0d3-d97d-47c4-a02c-298a5081c0f9.mock.pstmn.io/near/transactions?api_key=SECRET_API_KEY`

If you run into any issues with this endpoint, please stop and contact us immediately.

### Requirements
- A root index page with a list of transfers with the following fields: sender, receiver and deposit.
- A section on the page that shows the average gas burnt for all transactions.
- The app should show the historical transactions it was able to fetch already even if they are no longer returned by the API.
- Although we are using only NEAR in this example, it’s possible new chains will be added later.

### Additional Information
- Focus on the requirements. Do not spend any time on non-code-related environmental issues like setting up Docker, etc.
- The README should be thorough and complete. It should contain explanations of any questions you had, tradeoffs / decisions you made and the rationale behind them. Anyone should be able to view the README and immediately have any questions they might have about your project answered.
- If you do end up spending more than 3hrs on the task please detail the extra work you have done so that they are clearly noticed and credit given.

### On the Blockchain API Endpoint

- The API returns a list of Transactions, each of which was included in a Block. The “height” field represents the block number that the transaction was included in and is an incrementing integer.
- Even though our Mock API always returns the same data, the assumption should be that this API returns the X most recent transactions on the chain. If you called the API some time ago and call it again, you might see new transactions showing up and some of the older transactions are no longer listed.
- The `block_hash` is another unique identifier for the block, and “hash” is a unique identifier for the Transaction itself.
- In real life, a Transaction can have many Actions, but our example API only has one action per Transaction. For the UI, we’re interested in displaying transactions that include an action with type transfer.
- **Note:** not all transactions returned by the API are of type transfer.
- The Git history of the project should be representative of the work you do, and should communicate cleanly what each commit is doing.
- The mock endpoint will work without an API key, but assume it's required.
- Near token is a currency with a scale factor of 24, so for example deposit of 716669915088987500000000000 should be displayed as "716.6699150889875 NEAR".
- Don't scale gas.
- **Note:** not all transactions returned by the API are of type transfer.
- Styling and CSS are not important, but if you decided to use Tailwind or whatever to make a nice final product that will certainly be given credit.
- If you have any questions, and it is expected that you might, feel free to email us to ask any questions you have at rosa.adl@figment.io or by replying to this email.

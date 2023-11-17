const express = require('express');
const router = express.Router();
const stripe = require('stripe')('sk_test_51O1mwsSBFjpzQSTJcZbPFYDAWpuV5idzEE62s6n7QHEswXShSp8rJqmWZcejO5jvcTZWcBZHh063PDu2AgTKpneT00sISTulAG');

router.post('/customerPayment', async (req, res) => {
  try {
      let customerId;
      console.log(req.body);
      //Gets the customer who's email id matches the one sent by the client
      const customerList = await stripe.customers.list({
          limit: 100,
      });

      const matchingCustomers = customerList.data.filter(customer => {
        return (
          customer.name === req.body.name &&
          customer.phone === req.body.phone
        );
      });

      //Checks the if the customer exists, if not creates a new customer
      if (matchingCustomers.length) {
          customerId = matchingCustomers[0].id;
      }
      else {
          const customer = await stripe.customers.create({
              name:req.body.name,
              phone:req.body.phone,
          });
          customerId = customer.id;
      }

      //Creates a temporary secret key linked with the customer
      const ephemeralKey = await stripe.ephemeralKeys.create(
          { customer: customerId },
          { apiVersion: '2023-08-16' }
      );

      //Creates a new payment intent with amount passed in from the client
      const paymentIntent = await stripe.paymentIntents.create({
          amount: parseInt(req.body.amount),
          currency: 'INR',
          customer: customerId,
      })

      res.status(200).send({
          paymentIntent: paymentIntent.client_secret,
          ephemeralKey: ephemeralKey.secret,
          customer: customerId,
          success: true,
      })

  } catch (error) {
      res.status(404).send({ success: false, error: error.message })
  }
});

module.exports = router;

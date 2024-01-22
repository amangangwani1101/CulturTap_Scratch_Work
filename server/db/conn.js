const mongoose = require('mongoose');
mongoose.connect('mongodb+srv://utkarsh:utkarshG1234@culturtap.t5vwtzg.mongodb.net/userStoryDatabase?retryWrites=true&w=majority',{
    useNewUrlParser : true,
    useUnifiedTopology : true,
}).then(()=>{
    console.log('mongodb connected');
}).catch((error)=>{
console.log(error)
});
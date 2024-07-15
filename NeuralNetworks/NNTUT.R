# PRE-PROCESSING -> taking training and testing data

determine_class <- function(species) {
  cols <- c()
  for (s in species) {
    if (s == "versicolor") {
      cols <- c(cols, 0)
    }
    else {
      cols <- c(cols, 1)
    }
  }
  return(cols)
}

df <- mutate(ir_c, y = determine_class(Species)) 
df <- df [ , -5]

training <- rbind(df[1:40, ], df[51:90, ])  # train dataset
testing <- rbind(df[41:50, ], df[91:100, ]) # test dataset

x_training <- scale(training[ , c(3:4)])
y_training <- training$y
dim(y_training) <- c(length(y_training), 1) # add extra dimension to vector

x_testing <- scale(testing[ , c(3:4)])
y_testing <- testing$y
dim(y_testing) <- c(length(y_testing), 1) # add extra dimension to vector

# use matrices for easier manipulation
x_training <- as.matrix(x_training, byrow = TRUE)
x_training <- t(x_training) # taking transpose
y_training <- as.matrix(y_training, byrow = TRUE)
y_training <- t(y_training) # taking transpose


x_testing <- as.matrix(x_testing, byrow = TRUE)
x_testing <- t(x_testing) # taking transpose
y_testing <- as.matrix(y_testing, byrow = TRUE)
y_testing <- t(y_testing) # taking transpose 

# NN IMPL

# 1 define NN architecture

# 2 initialize model's parameters from random uniform distribution

# 3 loop (train)
##  implement forward propagation
##  compute error
##  implewment back propagation
##  update parameters

# get layer sizes
# n_x = # neurons in input layer
# n_h = # neurons in hidden layer
# n_y = # neurons in output layer
get_layer_size <- function(x, y, layer, training = TRUE) {
  n_x <- dim(x)[1]
  n_h <- layer
  n_y <- dim(y)[1]
  
  size <- list("n_x" = n_x,
               "n_h" = n_h,
               "n_y" = n_y)
  return(size)
}

# initialize parameters
# W1 = (n_h, n_x)
# b1 = (n_h, 1)
# W2 = (n_y, n_h)
# b2 = (n_y, 1)
initial_weights <- function(x, layer_size) {
  m <- dim(data.matrix(x))[2]
  n_x <- layer_size$n_x
  n_h <- layer_size$n_h
  n_y <- layer_size$n_y
  
  W1 <- matrix(runif(n_h * n_x), nrow = n_h, ncol = n_x, byrow = TRUE)
  b1 <- matrix(rep(0, n_h), nrow = n_h)
  W2 <- matrix(runif(n_y * n_h), nrow = n_y, ncol = n_h, byrow = TRUE)
  b2 <- matrix(rep(0, n_y), nrow = n_y)
  
  params <- list("W1" = W1,
                 "b1" = b1,
                 "W2" = W2,
                 "b2" = b2)
  
  return(params)
  
}

# sigmoid activation function
sigmoid <- function(x) {
  return(1 / (1 + exp(-x)))
}

# feed forward -> forward pass
# forward propagation computation
fwd_prop <- function(x, params, layer_size) {
  m <- dim(x)[2]
  n_h <- layer_size$n_h
  n_y <- layer_size$n_y
  
  W1 <- params$W1
  b1 <- params$b1
  W2 <- params$W2
  b2 <- params$b2
  
  b1_new <- matrix(rep(b1, m), nrow = n_h)
  b2_new <- matrix(rep(b2, m), nrow = n_y)
  
  Z1 <- W1 %*% x + b1_new # matrix multiply
  A1 <- sigmoid(Z1)
  Z2 <- W2 %*% A1 + b2_new
  A2 <- sigmoid(Z2)
  
  fwd_pass <- list("Z1" = Z1,
                   "A1" = A1,
                   "Z2" = Z2,
                   "A2" = A2)
  
  return(fwd_pass)
}

# params <- updated params from trained model here!!!

prediction <- function(x, y, layer, params) {
  layer_size <- get_layer_size(x, y, layer)
  fwd_pass <- fwd_prop(x, params, layer_size)
  pred <- fwd_pass$A2
  return(round(pred))
}


# compute error cost
error <- function(x, y, fwd_pass) {
  m <- dim(x)[2]
  A2 <- fwd_pass$A2
  
  log_diff <- (log(A2) * y) + (log(1-A2) * (1-y))
  
  error <- -sum(log_diff/m)
  
  return(error)
}

# backwards propagation
back_prop <- function(x, y, fwd_pass, params, layer_size) {
  m <- dim(x)[2]
  
  n_x <- layer_size$n_x
  n_h <- layer_size$n_h
  n_y <- layer_size$n_y
  
  A2 <- fwd_pass$A2
  A1 <- fwd_pass$A1
  W2 <- params$W2
  
  dZ2 <- A2 - y
  dW2 <- 1/m * (dZ2 %*% t(A1))
  db2 <- matrix(1/m * sum(dZ2), nrow = n_y)
  db2_new <- matrix(rep(db2, m), nrow = n_y)
  
  dZ1 <- (t(W2) %*% dZ2) * (1 - A1^2)
  dW1 <- 1/m * (dZ1 %*% t(x))
  db1 <- matrix(1/m * sum(dZ1), nrow = n_h)
  db1_new <- matrix(rep(db1, m), nrow = n_h)
  
  gradients <- list("dW1" = dW1,
                    "db1" = db1,
                    "dW2" = dW2, 
                    "db2" = db2)
  return(gradients)
}

# update weights
update_weights <- function(gradients, params) {
  
  W1 <- params$W1
  b2 <- params$b2
  W2 <- params$W2
  b2 <- params$b2
  
  dW1 <- gradients$dW1
  db1 <- gradients$db1
  dW2 <- gradients$dW2
  db2 <- gradients$db2
  
  W1 <- dW1
  b1 <- db1
  W2 <- dW2
  b2 <- db2
  
  params <- list("W1" = W1,
                 "b1" = b1,
                 "W2" = W2,
                 "b2" = b2)
  
  return(params)
}

# PUT TOGETHER
train_model <- function(x, y, iter, layer) {
  
  layer_size <- get_layer_size(x, y, layer)
  params <- initial_weights(x, layer_size)
  
  error_hist <- c()
  
  for(i in 1:iter) {
    fwd_pass <- fwd_prop(x, params, layer_size)
    error <- error(x, y, fwd_pass)
    back_pass <- back_prop(x, y, fwd_pass, params, layer_size)
    params <- update_weights(back_pass, params)
    error_hist <- c(error_hist, error)
  }
  
  model <- list("weights" = params,
                "error_hist" = error_hist)
  
  return(model)
}

# confusion matrix
# TN = True Negative, FP = False Positive
# FN = False Negative, TP = True Positive
#      0   1      
# 0 [ TN, FP ]
# 1 [ FN, TP ]
confusion_matrix(y, y_prediction) {
  tb_cm <- table(y, y_prediction)
  return(tb_cm)
}

# metrics of performance
# precision (p) =  number of true positives over the number of true positives plus the number of false positives
# recall (r)    =  number of true positives over the number of true positives plus the number of false negatives
# f1 score (f1) =  harmonic mean of precision and recall (2 * (p * r) / (p + r))
# accuracy (a)  =  percentage of the all correct predictions out total predictions made
metrics <- function(tb) {
  tn <- tb[1]
  tp <- tb[4]
  fn <- tb[3]
  fp <- tb[2]
  a <- (tp + tn) / (tp + fp + tn + fn)
  r <- tp / (tp + fn)
  p <- tp / (tp + fp)
  f1 <- 2 * ((p * r) / (p + r))
  
  metric <- list("acc" = a,
                 "rec" = r,
                 "prec" = p,
                 "f" = f1)
  return(metric)
}

# TESTING
trained <- train_model(x_training, y_training, iter = 10, layer = 4)

plot(1:10, trained$error_hist, xlab = "iteration", ylab = "error", type = "l")
points(1:10, trained$error_hist, pch = 16)

# train a simple logistic regression model to compare performance with our nn
lr_model <- glm(y ~ x1 + x2, data = train)
lr_model

# generate predictions of logistic regression model on test set
lr_pred <- round(as.vector(predict(lr_model, test[, 1:2])))
lr_pred



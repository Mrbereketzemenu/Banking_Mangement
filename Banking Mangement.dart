abstract class Account {
  final int accountNumber;
  String customerName;
  double balance;

  Account(this.accountNumber, this.customerName, {required this.balance});

  void deposit(double amount) {
    balance += amount;
  }

  void withdraw(double amount) {
    if (balance >= amount) {
      balance -= amount;
    } else {
      throw InsufficientFundsException(
          "Insufficient funds in account $accountNumber.");
    }
  }

  double getBalance() {
    return balance;
  }

  double calculateInterest() {
    return 0.0;
  }
}

class SavingsAccount extends Account {
  final double interestRate;

  SavingsAccount(
      int accountNumber, String customerName, double balance, this.interestRate)
      : super(accountNumber, customerName, balance: balance);

  @override
  void deposit(double amount) {
    super.deposit(amount);
    balance += balance * this.interestRate / 100;
  }

  @override
  double calculateInterest() {
    return balance * interestRate / 100;
  }
}

class CurrentAccount extends Account {
  final double transactionFee;

  CurrentAccount(int accountNumber, String customerName, double balance,
      this.transactionFee)
      : super(accountNumber, customerName, balance: balance);

  @override
  void withdraw(double amount) {
    super.withdraw(amount + transactionFee);
  }
}

class LoanAccount extends Account {
  final double interestRate;
  final DateTime maturityDate;

  LoanAccount(int accountNumber, String customerName, double balance,
      this.interestRate, this.maturityDate)
      : super(accountNumber, customerName, balance: balance);

  void makePayment(double amount) {
    if (amount > balance) {
      throw ExcessPaymentException(
          "your current amount is not enough to requesting a loan");
    }
    balance -= amount;
  }

  double calculateInterest() {
    final timeDifference = DateTime.now().difference(maturityDate).inDays;
    final interest = balance * interestRate * timeDifference / 36500;
    return interest;
  }
}

class InsufficientFundsException implements Exception {
  final String message;

  InsufficientFundsException(this.message);

  @override
  String toString() => message;
}

class ExcessPaymentException implements Exception {
  final String message;

  ExcessPaymentException(this.message);

  @override
  String toString() => message;
}

class Bank {
  final List<Account> accounts = [];

  Account? findAccount(int accountNumber) {
    return accounts
        .firstWhere((account) => account.accountNumber == accountNumber);
  }

  void createAccount(Account account) {
    accounts.add(account);
  }

  void transfer(int fromAccountNumber, int toAccountNumber, double amount) {
    final fromAccount = findAccount(fromAccountNumber);
    final toAccount = findAccount(toAccountNumber);
    if (fromAccount != null && toAccount != null) {
      try {
        fromAccount.withdraw(amount);
        toAccount.deposit(amount);
      } on InsufficientFundsException {
        print("Insufficient funds in account $fromAccountNumber.");
      }
    } else {
      print("Invalid account number(s)");
    }
  }

  void exampleUsage() {
    final savingsAccount =
        SavingsAccount(1000414017472, "Bereket Zemenu", 3000000, 5);
    final currentAccount =
        CurrentAccount(1000414017472, "Bereket Zemenu", 1500000, 2);
    final loanAccount = LoanAccount(100004367892, "Zemenu ejigu", 1500000, 10,
        DateTime.now().add(Duration(days: 365)));

    createAccount(savingsAccount);
    createAccount(currentAccount);
    createAccount(loanAccount);
    savingsAccount.deposit(500);
    print(
        "Savings account balance after deposit: ${savingsAccount.getBalance()}");

    try {
      currentAccount.withdraw(600);
    } on InsufficientFundsException catch (e) {
      print(e.toString());
    }

    transfer(savingsAccount.accountNumber, currentAccount.accountNumber, 200);
    print(
        "Savings account balance after transfer: ${savingsAccount.getBalance()}");
    print(
        "Current account balance after transfer: ${currentAccount.getBalance()}");
    final loanInterest = loanAccount.calculateInterest();
    print("Loan account interest: $loanInterest");
  }
}

void main() {
  final bank = Bank();
  bank.exampleUsage();
}

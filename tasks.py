#Basic Calculator

def calculate(num1, operator, num2):
    if operator =='+':
        return num1+num2
    elif operator =='-':
        return num1-num2
    elif operator =='*':
        return num1*num2
    elif operator =='/':
        return "Error!." if num2==0 else num1/num2
    else:
        return "Invalid operator"
def calculator():
    try:
        num1=float(input("Enter first number: "))
        operator=input("Enter operator(+,-,*,/): ")
        num2=float(input("Enter second number: "))

        print(f"Result: {calculate(num1, operator, num2)}")
    except ValueError:
        print("Invalid input. Please enter numbers only.")
calculator()

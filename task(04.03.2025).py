#1. Input: "hello" → Output: "olleh"

word_to_input='hello'

reverse_ver=word_to_input[::-1]

print(reverse_ver)

# Input: "hello" → Output: "olleh"

#2. Count Vowels: Matnda nechta unli harf borligini aniqlang (a, e, i, o, u).

def count_vowels(statement):
    vowels='aeiouAEIOU'
    return sum(statement.count(vowel) for vowel in vowels)

statetment="programming"
print(count_vowels(statetment))

# Input: "programming" → Output: 3

    
#3. Palindrome Checker: So‘z palindrom ekanligini tekshiring.

def if_palindrome(word):
    if word==word[::-1]:
        return True
    else:
        return False
word='level'
    
print(if_palindrome(word))


# Input: "level" → Output: True

#4. First Unique Character: Berilgan matnda birinchi takrorlanmagan harfni toping.

def first_unique_character(a):
    for char in a:
        if a.count(char)==1:
            return char
    return None
    
print(first_unique_character("swiss"))

# Input: "swiss" → Output: "w"


#5. Anagram Checker: Ikkita so‘z anagram ekanligini tekshiring (harflari bir xil, lekin tartibi farq qiladi).

def is_anagram(w1, w2):
    return sorted(w1)==sorted(w2)
print(is_anagram("listen", "silent"))

# Input: ("listen", "silent") → Output: True

#6. Remove Duplicates: Matndan takrorlangan harflarni olib tashlang.

def remove_duplicates(w):
    return "".join(dict.fromkeys(w))

print(remove_duplicates("banana"))

# Input: "banana" → Output: "ban"

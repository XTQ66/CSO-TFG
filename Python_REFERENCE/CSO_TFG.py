import random
import logging
import sympy


# Generate random polynomials
def generate_random_polynomial(N, q):
    return [random.randint(0, q - 1) for _ in range(N)]


def reverse_bits(x, N):
    """
     reverse the binary bits of an integer (N-bit width)
    :param x: Integers to be inverted
    :param N: bit-width
    :return:  reverse integer
    """
    result = 0
    for i in range(N):
        result = (result << 1) | (x & 1)
        x >>= 1
    return result


def generate_reversed_bit_sequence(N):
    """
    Generates numbers from 0 to 2^N-1 in N-bit-reversed order.
    :param N: bit-width
    :return: List of numbers in bit-reversed order
    """
    max_num = 2 ** N
    reversed_sequence = [reverse_bits(i, N) for i in range(max_num)]
    return reversed_sequence


def generate_psi(primitive_root, n, q):
    """
    Generate an array of twiddle factors (psi) and arrange them in log(n) bit-reversed order.
    :param primitive_root: The original root in mode q
    :param n: NTT length (must be a power of 2)
    :param q: modulus
    :return: Array of twiddle factors in bit-reversed order
    """
    # Computing log2(n)
    log_n = n.bit_length() - 1

    # Initialize the array of twiddle factors
    psi = [1] * n
    current_factor = primitive_root % q

    #  Stepwise cumulative multiplication to generate twiddle factors
    for i in range(1, n):
        psi[i] = (psi[i - 1] * current_factor) % q

    # Generate bit-reversed indexes
    reversed_indices = generate_reversed_bit_sequence(log_n)

    # Rearranging psi arrays
    psi_reversed = [psi[reversed_indices[i]] for i in range(n)]

    return psi_reversed


# # test
# if __name__ == "__main__":
#     q = 17            #  Modulus (needs to be prime)
#     n = 16            #  Length of NTT (must be a power of 2)
#     primitive_root = 3  # 
#
#     # Generate an array of twiddle factors
#     psi = generate_psi(primitive_root, n, q)
#     print("Array of bit-reversed twiddle factors (psi):", psi)

def ntt_forward(P, n, q, psi):
    """
    Cooley-Tukey Forward NTT.

    Parameters:
    P   -- Input array of length n
    n   -- Length of NTT (must be a power of 2)
    q   -- modulus
    psi -- Array of twiddle factors (already stored in bit-reversed order as a subdivision of the n original twiddle factors)

    Return:
    a   --  FHE-oriented NTT(P)
    """
    m = 1
    k = n // 2
    a = P.copy()
    # Iterative processing of butterfly operations at each level
    while m < n:
        for i in range(m):
            jFirst = 2 * i * k
            jLast = jFirst + k - 1
            psi_i = psi[m + i]

            for j in range(jFirst, jLast + 1):
                l = j + k
                t = a[j]
                u = a[l] * psi_i % q

                a[j] = (t + u) % q
                a[l] = (t - u) % q

        m *= 2
        k //= 2

    return a


def reverse_bits(x, num_bits):
    """
    The integer x is bit-reversed by num_bits.
    :param x: Input integer
    :param num_bits: bit-width
    :return: reversed integer
    """
    result = 0
    for i in range(num_bits):
        result = (result << 1) | (x & 1)
        x >>= 1
    return result

#Key Functions of FFO-TFG

def generate_gtf(phi, N, q):
    """
    Generate global twiddle factor GTF.
    :param phi: Initial twiddle factor
    :param N: NTT Length
    :param q: modulus
    :return: GTF arrays
    """
    logN = N.bit_length() - 1
    GTF = [1] * (2 * logN)  # Initialize GTF with size 2 * logN, default value is 1
    GTF[0] = phi % q
    for i in range(1, logN):
        GTF[i] = pow(GTF[i - 1], 2, q)
    #Holding logN to 2*logN to 1 is done at initialization time.
    return GTF


def butterfly_computation(x, y, twiddle, q):
    """
    Performing NTT butterfly operations
    :param x: Input polynomial coefficients x
    :param y: Input polynomial coefficients y
    :param twiddle: twiddle factor
    :param q: modulus
    :return: Calculated x and y
    """
    t = (y * twiddle) % q
    y_new = (x - t) % q
    x_new = (x + t) % q
    return x_new, y_new


import numpy as np

def compute_stf(n, N, GTF, q, i):
    """
    Calculate the STF array for the NTT of the ith stage
    :param n: Nmubers of MM
    :param N: NTT length
    :param GTF: Twiddle factors Arrays
    :param q: Modulus
    :return: Calculated STF 
    """
    STF = [GTF[int(np.log2(N)) - 1 - i] for _ in range(n)]  #Initialize STF
    logN = int(np.log2(N))  # Calculate log2(N)
    logn = int(np.log2(n))  # Calculate log2(n)

    temp = logn - (logN - 1 - i)  # Calculate temp
    for j in range(temp):
        # Batch Update STF Vector Segments
        step_size = 2 ** (j + logN - i - 1)
        start = step_size
        end = start + step_size
        # Segment update
        STF[start:end] = [(val * GTF[logN - 1 - j]) % q for val in STF[start:end]]
        # Segment replication
        for sub_index in range(1, n // (2 ** (j + logN - i))):
            start_copy = sub_index * step_size * 2
            end_copy = start_copy + step_size * 2
            STF[start_copy:end_copy] = STF[:end]
    return STF



def optimized_ntt(P, phi, n, N, q):
    """
    NTT with FFO-TFG Scheme
    :param P: Input polynomials
    :param phi: twiddle factor
    :param n: Number of MM 
    :param N: NTT length
    :param q: Modulus
    :return: FHE-Oriented NTT(P)
    """
    logN = N.bit_length() - 1
    logn = n.bit_length() - 1

    # 1. Initilization GTF (Global Twiddle Factors)
    GTF = generate_gtf(phi, N, q)

    # 2. NTT Main Loop
    for i in range(logN):
        # 2.1 Generate STF (Stage Twiddle Factors) , correspond to the current stage of the twiddle factor
        STF = compute_stf(n, N, GTF, q, i)

        # 2.2 Implementation of each stage of NTT
        # for j in range(2 ** i):
        #     for k in range(N // 2 // (2 ** i)):]
        temp = min((2 ** i), N // 2 // n)
        for j in range(temp):
            for k in range(N // 2 // temp):
                index = reverse_bits(j, logN - 1) + k
                index0 = (index // (N // (2 ** (i + 1)))) * (N // (2 ** i)) + index % (N // (2 ** (i + 1)))
                index1 = index0 + N // (2 ** (i + 1))

                # butterfly operation
                P[index0], P[index1] = butterfly_computation(P[index0], P[index1], STF[k % n], q)

            # Update STF
            STF = [(stf * GTF[logN - i]) % q for stf in STF]

    return P


def is_prime(n):
    return sympy.isprime(n)


def find_primitive_root(q):
    return sympy.primitive_root(q)


# Conducting full-scale testing
max_random = 20000000
for N in [2 ** i for i in range(1, 17)]:
    for n in [2 ** j for j in range(0, (N // 2).bit_length())]:
        try:
            # Randomly generate the modulus q
            q = random.randint(max_random / 2, max_random)
            while not is_prime(q):
                q = random.randint(max_random / 2, max_random)
            # Randomly generate primitive_root
            primitive_root = q - random.randint(10000, 20000)
            # Randomly generate polynomials P
            P = generate_random_polynomial(N, q)
            # Generate twiddle factors psi
            psi = generate_psi(primitive_root, N, q)
            # Naive NTT
            result = ntt_forward(P, N, q, psi)
            # Optimized NTT with FFO-TFG
            transformed_P = optimized_ntt(P.copy(), primitive_root, n, N, q)
            # Check Result 
            if transformed_P == result:
                print(f"q = {q}, phi = {primitive_root}, N = {N}, n = {n}: Match!")
            else:
                logging.error(f"q = {q}, N = {N}, n = {n}: Not Match!")
        except Exception as e:
            logging.error(f"Error encountered for N = {N}, n = {n}: {e}")

# 
# if __name__ == "__main__":
# # 
# q = 17334667 # Modulus (needs to be prime)
# N = 65536  # NTT size (must be a power of 2)
# n = 1024  # Number of MMs (must be a power of 2)
# # Generate a random polynomial P
# P = generate_random_polynomial(N, q)
# # P = [1, 1, 1, 1, 1, 1, 1, 1]  # Input polynomials
# primitive_root = 3627374  # 
# # 
# psi = generate_psi(primitive_root, N, q)  # 
# # print("Input polynomials P:", P)
# # print("Input n powers of primitive_root :", psi)
# # Naive NTT
# result = ntt_forward(P, N, q, psi)
# # print("NTT :", result)
# # Optimized NTT with FFO-TFG
# transformed_P = optimized_ntt(P, primitive_root, n, N, q)
# # print("Optimized NTT with Run-time TF generator:", transformed_P)
# if transformed_P == result:
#     print(f"q = {q}, phi = {primitive_root}, N = {N}, n = {n}  Match!")
# else:
#     logging.error("Not Match!")



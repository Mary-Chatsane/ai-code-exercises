## Exercise: Performance Optimization Challenge
## Slow Code Analysis  (python)

**Applied Prompt 1: slow code analysis**
 
I have a piece of code that's running slowly. I'd like to understand why and how to improve it.

Here's the slow-performing code:

[# inventory_analysis.py
def find_product_combinations(products, target_price, price_margin=10):
    """
    Find all pairs of products where the combined price is within
    the target_price ± price_margin range.

    Args:
        products: List of dictionaries with 'id', 'name', and 'price' keys
        target_price: The ideal combined price
        price_margin: Acceptable deviation from the target price

    Returns:
        List of dictionaries with product pairs and their combined price
    """
    results = []

    # For each possible pair of products
    for i in range(len(products)):
        for j in range(len(products)):
            # Skip comparing a product with itself
            if i != j:
                product1 = products[i]
                product2 = products[j]

                # Calculate combined price
                combined_price = product1['price'] + product2['price']

                # Check if the combined price is within the target range
                if (target_price - price_margin) <= combined_price <= (target_price + price_margin):
                    # Avoid duplicates like (product1, product2) and (product2, product1)
                    if not any(r['product1']['id'] == product2['id'] and
                               r['product2']['id'] == product1['id'] for r in results):

                        pair = {
                            'product1': product1,
                            'product2': product2,
                            'combined_price': combined_price,
                            'price_difference': abs(target_price - combined_price)
                        }
                        results.append(pair)

    # Sort by price difference from target
    results.sort(key=lambda x: x['price_difference'])
    return results

 #Example usage
if __name__ == "__main__":
    import time
    import random

    # Generate a large list of products
    product_list = []
    for i in range(5000):
        product_list.append({
            'id': i,
            'name': f'Product {i}',
            'price': random.randint(5, 500)
        })

    # Measure execution time
    start_time = time.time()
    combinations = find_product_combinations(product_list, 500, 50)
    end_time = time.time()

    print(f"Found {len(combinations)} product combinations")
    print(f"Execution time: {end_time - start_time:.2f} seconds")]

Context about the issue:
- What this code is supposed to do: This code is used in an e-commerce application to suggest product pairs that match a target price point
- Typical input size/data: The function typically processes 5,000+ products
- Current performance: Approximately 20-30 seconds for 5,000 products
- Environment: Python 3.9 on a web server with 4GB RAM

Could you please:
1. Explain in simple terms why this code might be slow
2. Identify the specific operations or patterns that are likely causing the slowdown
3. Suggest 2-3 specific improvements I could make
4. Explain the performance concepts I should learn to avoid similar issues in the future
5. If there are any tools or techniques I could use to measure the actual bottlenecks, please suggest them

I'm particularly interested in learning the underlying performance concepts, not just getting a quick fix.


---
**Suggested optimization**

*why there's slow performance* 

There's comparison of every product against every other product — with 5,000 products, that's roughly 25 million comparisons (5,000 × 5,000). That volume alone would be slow in Python, but there's a second, hidden cost stacked on top: for every pair that does match, scanning through the entire results list so far to check if it's already added the reverse pair. As the results list grows, each of those checks gets slower — so the slowdown compounds as the function runs, not just stays constant.

Fix 1 — stop checking pairs twice (removes the need for duplicate-checking entirely).This alone removes the expensive any() scan completely, since each pair is now only ever considered once. This should give a significant speedup on its own.

Fix 2 — the bigger structural change: sort first, then use two pointers. This is the real algorithmic improvement, going from "compare everything to everything" (O(n²)) down to "sort once, then scan in one pass" (O(n log n))

**Implementing optimization**

**results after Claude implemented the above:**





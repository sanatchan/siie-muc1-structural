import os

def universal_pdb_fixer(input_filename, output_filename):
    with open(input_filename, 'r') as f_in, open(output_filename, 'w') as f_out:
        for line in f_in:
            parts = line.split()
            
            # Skip empty lines or non-atom lines
            if not parts or parts[0] not in ["ATOM", "HETATM"]:
                f_out.write(line)
                continue
                
            try:
                # 1. Identify the pieces based on column count
                # If chain and res_no are squashed (like B1320), parts[4] will be 'B1320'
                if len(parts[4]) > 1 and not parts[4].isalpha():
                    chain = parts[4][0]        # 'B'
                    res_no = parts[4][1:]      # '1320'
                    # Re-map the rest of the columns because they shifted left
                    x, y, z = parts[5], parts[6], parts[7]
                    occ, temp = parts[8], parts[9]
                else:
                    # Normal spacing (A 710)
                    chain = parts[4]
                    res_no = parts[5]
                    x, y, z = parts[6], parts[7], parts[8]
                    occ, temp = parts[9], parts[10]

                # 2. Extract standard fields
                rtype = parts[0]
                serial = parts[1]
                name = parts[2]
                res_name = parts[3]

                # 3. Handle Atom Name alignment (The 14th column rule)
                if len(name) < 4:
                    name_fmt = f" {name:<3}"
                else:
                    name_fmt = f"{name:<4}"

                # 4. Write the STRICT fixed-column line
                # Each {} has a specific width (e.g., :>8.3f is 8 chars total)
                fixed_line = (
                    f"{rtype:<6}"            # 1-6
                    f"{int(serial):>5} "     # 7-11
                    f"{name_fmt:4} "         # 13-16
                    f"{res_name:>3} "        # 18-20
                    f"{chain}"               # 21
                    f"{int(res_no):>4}    "   # 23-26
                    f"{float(x):>8.3f}"      # 31-38
                    f"{float(y):>8.3f}"      # 39-46
                    f"{float(z):>8.3f}"      # 47-54
                    f"{float(occ):>6.2f}"    # 55-60
                    f"{float(temp):>6.2f}"   # 61-66
                    f"\n"
                )
                f_out.write(fixed_line)

            except Exception as e:
                # If something goes wrong, just write the original line
                f_out.write(line)

# --- Loop Through Files 1 to 10 ---
for i in range(0, 11):
    input_file = f"complex.{i}.pdb"
    output_file = f"fixed_complex.{i}.pdb"
    
    # Optional safety check: only process the file if it actually exists in your folder
    if os.path.exists(input_file):
        print(f"Processing: {input_file} -> {output_file}")
        universal_pdb_fixer(input_file, output_file)
    else:
        print(f"Skipping: {input_file} (File not found)")

print("\nAll transformations finished! You can now open the 'fixed_complex.*.pdb' files in ChimeraX.")

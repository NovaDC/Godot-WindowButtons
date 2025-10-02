#!/usr/bin/env bash
set -euo pipefail

sed_rules=()
keys=()
safe_vals=()

for arg in "$@";
do
	key="${arg%%=*}"
	val="${arg#*=}"

	# rules
	sed_rules+=("s/${key//\//\\/}/${val//\//\\/}/g")
	keys+=("$key")
	# sanitised
	safe_vals+=("$(printf '%s' "$val" | tr '/\\:*?"<>|' '_' )")
done

# content replace
for rule in "${sed_rules[@]}";
do
	find . -type f \
		-not -path './.git/*' \
		-not -path './.github/workflows/*' \
		-exec perl -pi -e "$rule" {} +
done

# rename paths
for i in "${!keys[@]}";
do
   k="${keys[$i]}"; safe_v="${safe_vals[$i]}"

	# dirs
	find . -depth -type d \
		-not -path './.git/*' \
		-not -path './.github/workflows/*' \
		-name "*$k*" -print0 |
	sort -rz |
	while IFS= read -r -d '' dir;
	do
		new="${dir//$k/$safe_v}"
		[[ $new == "$dir" ]] && continue

		if [[ -e $new ]];
		then
			shopt -s dotglob nullglob
			for item in "$dir"/*;
			do
				mv "$item" "$new"/
			done
			rmdir "$dir"
		else
			mkdir -p "$(dirname "$new")"
			mv "$dir" "$new"
		fi
	done

	# files
	find . -depth -type f \
		-not -path './.git/*' \
		-not -path './.github/workflows/*' \
		-name "*$k*" -print0 |
	sort -rz |
	while IFS= read -r -d '' file;
	do
		new="${file//$k/$safe_v}"
		[[ $new == "$file" ]] && continue
		mkdir -p "$(dirname "$new")"
		mv "$file" "$new"
	done
done

echo "Done!"

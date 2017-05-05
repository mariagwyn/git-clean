#!/bin/bash
# git-cleanup-repo
#
# Adapted by: Shay Smith <shay.smith@acquia.com>
# Adapted from: Rob Miller <rob@bigfish.co.uk>
# Who adapted from the original by Yorick Sijsling
# https://gist.github.com/robmiller/5133264

git checkout master &> /dev/null

# Make sure we're working with the most up-to-date version of master.
git fetch

# Prune obsolete remote tracking branches. These are branches that we
# once tracked, but have since been deleted on the remote.
git remote prune origin

# List all the branches that have been merged fully into master, and
# then delete them. We use the remote master here, just in case our
# local master is out of date.
git branch --list *AcquiaRA* --merged | grep -v 'master$' | xargs git branch -d

read -p "Remove(A)ll RA branches or just RA Branches that have(M)erged with master (A/M)? "
if [ "$REPLY" == "M" ]; then
	# Now the same, but including remote branches.
	MERGED_ON_REMOTE=`git branch -r --list *AcquiaRA* --merged | sed 's/ *origin\///' | grep -v 'master$'`
	if [ "$MERGED_ON_REMOTE" ]; then
		echo "The following remote branches created by RA are fully merged and will be removed:"
		printf "%s\n" "${MERGED_ON_REMOTE[@]}"

		read -p "Continue (Y/n)? "
		if [ "$REPLY" == "Y" ]; then
			git branch -r --list *AcquiaRA* --merged | sed 's/ *origin\///' \
				| grep -v 'master$' | xargs -I% git push origin :% 2>&1 \
				| grep --colour=never 'deleted'
			echo "Done!"
		fi
	fi

elif [ "$REPLY" == "A" ]; then
	NOTMERGED_ON_REMOTE=`git branch -r --list *AcquiaRA* | sed 's/ *origin\///' | grep -v 'master$'`
	if [ "$NOTMERGED_ON_REMOTE" ]; then
		echo "The following remote branches created by RA may not be fully merged and will be removed:"
		printf "%s\n" "${NOTMERGED_ON_REMOTE[@]}"

		read -p "Continue (Y/n)? "
		if [ "$REPLY" == "Y" ]; then
			git branch -r --list *AcquiaRA* | sed 's/ *origin\///' \
				| grep -v 'master$' | xargs -I% git push origin :% 2>&1 \
				| grep --colour=never 'deleted'
			echo "Done!"
		fi
	fi

else
	echo "Halting. I don't understand your response."
fi
